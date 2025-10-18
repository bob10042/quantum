#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef void (*DerivativeFunc)(double t, const double *state, double *dstate,
                               void *params);

typedef struct {
    double sigma;
    double rho;
    double beta;
} LorenzParams;

typedef struct {
    double *k1;
    double *k2;
    double *k3;
    double *k4;
    double *scratch;
    int dimension;
} RK4Workspace;

static void rk4_workspace_free(RK4Workspace *ws);

static int rk4_workspace_init(RK4Workspace *ws, int dimension) {
    ws->dimension = 0;
    ws->k1 = ws->k2 = ws->k3 = ws->k4 = ws->scratch = NULL;

    size_t bytes = (size_t)dimension * sizeof(double);
    ws->k1 = (double *)malloc(bytes);
    ws->k2 = (double *)malloc(bytes);
    ws->k3 = (double *)malloc(bytes);
    ws->k4 = (double *)malloc(bytes);
    ws->scratch = (double *)malloc(bytes);
    if (!ws->k1 || !ws->k2 || !ws->k3 || !ws->k4 || !ws->scratch) {
        rk4_workspace_free(ws);
        return -1;
    }
    ws->dimension = dimension;
    return 0;
}

static void rk4_workspace_free(RK4Workspace *ws) {
    free(ws->k1);
    free(ws->k2);
    free(ws->k3);
    free(ws->k4);
    free(ws->scratch);
    ws->k1 = ws->k2 = ws->k3 = ws->k4 = ws->scratch = NULL;
    ws->dimension = 0;
}

static void rk4_step(double t, double dt, const double *state, double *next_state,
                     DerivativeFunc derivative, void *params,
                     RK4Workspace *workspace) {
    int dim = workspace->dimension;
    double half_dt = dt * 0.5;
    double sixth_dt = dt / 6.0;

    derivative(t, state, workspace->k1, params);

    for (int i = 0; i < dim; ++i) {
        workspace->scratch[i] = state[i] + half_dt * workspace->k1[i];
    }
    derivative(t + half_dt, workspace->scratch, workspace->k2, params);

    for (int i = 0; i < dim; ++i) {
        workspace->scratch[i] = state[i] + half_dt * workspace->k2[i];
    }
    derivative(t + half_dt, workspace->scratch, workspace->k3, params);

    for (int i = 0; i < dim; ++i) {
        workspace->scratch[i] = state[i] + dt * workspace->k3[i];
    }
    derivative(t + dt, workspace->scratch, workspace->k4, params);

    for (int i = 0; i < dim; ++i) {
        next_state[i] =
            state[i] +
            sixth_dt *
                (workspace->k1[i] + 2.0 * workspace->k2[i] +
                 2.0 * workspace->k3[i] + workspace->k4[i]);
    }
}

static void integrate_system(double t0, double dt, size_t steps, double *state,
                             int dimension, DerivativeFunc derivative,
                             void *params, FILE *log_stream,
                             size_t log_interval) {
    RK4Workspace workspace;
    if (rk4_workspace_init(&workspace, dimension) != 0) {
        fprintf(stderr, "Failed to allocate RK4 workspace.\n");
        exit(EXIT_FAILURE);
    }

    double *current_state = (double *)malloc((size_t)dimension * sizeof(double));
    double *next_state = (double *)malloc((size_t)dimension * sizeof(double));
    if (!current_state || !next_state) {
        fprintf(stderr, "Failed to allocate state buffers.\n");
        rk4_workspace_free(&workspace);
        free(current_state);
        free(next_state);
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i < dimension; ++i) {
        current_state[i] = state[i];
    }

    fprintf(log_stream, "t");
    for (int i = 0; i < dimension; ++i) {
        fprintf(log_stream, ",x%d", i + 1);
    }
    fputc('\n', log_stream);

    double t = t0;
    for (size_t step = 0; step < steps; ++step) {
        if (log_interval != 0 && (step % log_interval) == 0) {
            fprintf(log_stream, "%.10f", t);
            for (int i = 0; i < dimension; ++i) {
                fprintf(log_stream, ",%.10f", current_state[i]);
            }
            fputc('\n', log_stream);
        }
        rk4_step(t, dt, current_state, next_state, derivative, params,
                 &workspace);
        for (int i = 0; i < dimension; ++i) {
            current_state[i] = next_state[i];
        }
        t += dt;
    }

    fprintf(log_stream, "%.10f", t);
    for (int i = 0; i < dimension; ++i) {
        fprintf(log_stream, ",%.10f", current_state[i]);
    }
    fputc('\n', log_stream);

    for (int i = 0; i < dimension; ++i) {
        state[i] = current_state[i];
    }
    free(current_state);
    free(next_state);
    rk4_workspace_free(&workspace);
}

static void lorenz_derivative(double t, const double *state, double *dstate,
                              void *params) {
    (void)t;
    LorenzParams *p = (LorenzParams *)params;
    double x = state[0];
    double y = state[1];
    double z = state[2];

    dstate[0] = p->sigma * (y - x);
    dstate[1] = x * (p->rho - z) - y;
    dstate[2] = x * y - p->beta * z;
}

static void print_usage(const char *program_name) {
    fprintf(stderr,
            "Usage: %s [options]\n"
            "Options:\n"
            "  --dt <value>            Time step size (default: 0.01)\n"
            "  --steps <count>         Number of integration steps (default: "
            "10000)\n"
            "  --sigma <value>         Lorenz sigma parameter (default: 10)\n"
            "  --rho <value>           Lorenz rho parameter (default: 28)\n"
            "  --beta <value>          Lorenz beta parameter (default: 8/3)\n"
            "  --x0 <value>            Initial x coordinate (default: 1)\n"
            "  --y0 <value>            Initial y coordinate (default: 1)\n"
            "  --z0 <value>            Initial z coordinate (default: 1)\n"
            "  --log-interval <value>  Log every N steps (default: 1, set 0 to "
            "log final state only)\n"
            "  --output <file>         Write CSV output to file instead of stdout\n"
            "  --help                  Show this message and exit\n",
            program_name);
}

static int parse_double(const char *text, double *out_value) {
    char *endptr = NULL;
    errno = 0;
    double value = strtod(text, &endptr);
    if (errno != 0 || endptr == text || *endptr != '\0') {
        return -1;
    }
    *out_value = value;
    return 0;
}

static int parse_size_t(const char *text, size_t *out_value) {
    char *endptr = NULL;
    errno = 0;
    unsigned long long value = strtoull(text, &endptr, 10);
    if (errno != 0 || endptr == text || *endptr != '\0') {
        return -1;
    }
    *out_value = (size_t)value;
    return 0;
}

int main(int argc, char **argv) {
    double dt = 0.01;
    size_t steps = 10000;
    double state[3] = {1.0, 1.0, 1.0};
    size_t log_interval = 1;
    const char *output_path = NULL;

    LorenzParams parameters = {.sigma = 10.0, .rho = 28.0, .beta = 8.0 / 3.0};

    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--help") == 0) {
            print_usage(argv[0]);
            return EXIT_SUCCESS;
        } else if (strcmp(argv[i], "--dt") == 0 && (i + 1) < argc) {
            if (parse_double(argv[++i], &dt) != 0 || dt <= 0.0) {
                fprintf(stderr, "Invalid value for --dt\n");
                return EXIT_FAILURE;
            }
        } else if (strcmp(argv[i], "--steps") == 0 && (i + 1) < argc) {
            if (parse_size_t(argv[++i], &steps) != 0 || steps == 0) {
                fprintf(stderr, "Invalid value for --steps\n");
                return EXIT_FAILURE;
            }
        } else if (strcmp(argv[i], "--sigma") == 0 && (i + 1) < argc) {
            if (parse_double(argv[++i], &parameters.sigma) != 0) {
                fprintf(stderr, "Invalid value for --sigma\n");
                return EXIT_FAILURE;
            }
        } else if (strcmp(argv[i], "--rho") == 0 && (i + 1) < argc) {
            if (parse_double(argv[++i], &parameters.rho) != 0) {
                fprintf(stderr, "Invalid value for --rho\n");
                return EXIT_FAILURE;
            }
        } else if (strcmp(argv[i], "--beta") == 0 && (i + 1) < argc) {
            if (parse_double(argv[++i], &parameters.beta) != 0) {
                fprintf(stderr, "Invalid value for --beta\n");
                return EXIT_FAILURE;
            }
        } else if (strcmp(argv[i], "--x0") == 0 && (i + 1) < argc) {
            if (parse_double(argv[++i], &state[0]) != 0) {
                fprintf(stderr, "Invalid value for --x0\n");
                return EXIT_FAILURE;
            }
        } else if (strcmp(argv[i], "--y0") == 0 && (i + 1) < argc) {
            if (parse_double(argv[++i], &state[1]) != 0) {
                fprintf(stderr, "Invalid value for --y0\n");
                return EXIT_FAILURE;
            }
        } else if (strcmp(argv[i], "--z0") == 0 && (i + 1) < argc) {
            if (parse_double(argv[++i], &state[2]) != 0) {
                fprintf(stderr, "Invalid value for --z0\n");
                return EXIT_FAILURE;
            }
        } else if (strcmp(argv[i], "--log-interval") == 0 && (i + 1) < argc) {
            if (parse_size_t(argv[++i], &log_interval) != 0) {
                fprintf(stderr, "Invalid value for --log-interval\n");
                return EXIT_FAILURE;
            }
        } else if (strcmp(argv[i], "--output") == 0 && (i + 1) < argc) {
            output_path = argv[++i];
        } else {
            fprintf(stderr, "Unknown or incomplete option: %s\n", argv[i]);
            print_usage(argv[0]);
            return EXIT_FAILURE;
        }
    }

    FILE *output = stdout;
    if (output_path != NULL) {
        output = fopen(output_path, "w");
        if (!output) {
            perror("Failed to open output file");
            return EXIT_FAILURE;
        }
    }

    integrate_system(0.0, dt, steps, state, 3, lorenz_derivative,
                     &parameters, output, log_interval);

    if (output_path != NULL) {
        fclose(output);
    }

    fprintf(stderr,
            "Integration complete. Final state: x=%.6f, y=%.6f, z=%.6f\n",
            state[0], state[1], state[2]);
    return EXIT_SUCCESS;
}
