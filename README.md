# ChainDb

ChainDb is an experimental single-threaded runtime and in-memory database written in Chez Scheme.

The project is built from the mechanism upward:

```text
continuation → scheduler/ready queue → event loop → async I/O → protocol → commands → storage
```

The current alpha proves one complete path through that stack. A POSIX FIFO is polled without blocking the runtime, incoming bytes are decoded into commands, the dispatcher schedules command thunks, and an in-memory hash table stores bytevector keys and values. `GET` can yield through a captured continuation and later resume; short operations such as `PUT` complete in one dispatcher turn.

## Implemented in the alpha

- cooperative task queue based on `call/cc`;
- non-blocking FIFO polling and multi-chunk bytevector accumulation;
- byte-native command parser with symbolic opcodes;
- `PUT` and `GET` command tasks;
- content-based bytevector keys using `equal-hash` and `bytevector=?`;
- focused parser, command/storage, and FIFO tests.

The command protocol is intentionally small and is not intended to clone Redis. It will grow from ChainDb's runtime model and actual requirements.

## Layout

```text
bin/main.sps                    runtime entry point
src/chainDb/dispatcher.sls      scheduler and continuation-based yield
src/chainDb/pipe.sls            non-blocking FIFO source
src/chainDb/commands.sls        command-to-task translation
src/chainDb/commands/parser.sls byte-native protocol decoder
src/chainDb/commands/storage.sls in-memory bytevector storage
src/chainDb/test/               executable tests
experiments/                    research code kept outside the runtime
docs/                           architecture notes
context/                        local GitHub issue and wiki snapshots
```

## Running

Chez Scheme must be able to find libraries under `src`:

```sh
chez --libdirs src --script bin/main.sps
```

The current FIFO source opens `my_test_pipe` in the working directory. Create it before starting the runtime:

```sh
mkfifo my_test_pipe
```

## Tests

Run the byte-native parser and command/storage test with:

```sh
chez --libdirs src --script src/chainDb/test/test_validate_command.ss
```

`src/chainDb/test/test_lib_pipe.ss` is the current FIFO accumulation test. It expects `my_test_pipe` to exist and exercises a payload larger than the internal read buffer.

## Status

This is an alpha release and a proof of the runtime architecture. Protocol validation, client-facing responses, additional commands, and broader I/O sources remain future work.
