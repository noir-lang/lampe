# The Noir Standard Library

The Noir [Standard Library](https://github.com/noir-lang/noir/tree/master/noir_stdlib) (stdlib) is a
collection of code that is automatically made available to all Noir programs. This availability is
either from the [prelude](https://github.com/noir-lang/noir/blob/master/noir_stdlib/src/prelude.nr),
which is automatically imported into every module, or from direct imports. This means that every
Noir crate depends on it, and hence that it becomes part of the verification surface for an
arbitrary crate. To that end, it is very important that Lampe provide theorems for the standard
library that can be used to prove properties of any code that _uses_ the stdlib.

This extraction of the standard library (and its accompanying theorems) is automatically made
available to any extracted project by being written as a dependency into the generated
`lakefile.toml`. As a user, you can import the files containing the theorems (and the definitions)
that you need, just like you would import from the standard library in your Noir code.

> ### Unconstrained Code
>
> The standard library contains functions that are marked as `unconstrained`. The property
> verification by Lampe cannot directly verify the behavior of these functions, and so they are
> extracted with an empty body.

## Structure

Lampe's copy of the standard library follows the same structure as is the default for any extracted
project. For a detailed description of this structure, see the documentation on the
[extracted project structure](../docs/Extracted Project Structure.md). The extracted `lampe`
directory is located right next to the `src` directory of the standard library project.

For the stdlib, the theorems—along with the corresponding re-exported definitions—are available
under `Stdlib.Mod`, for the file that corresponds to `mod.nr`. The definitions are
in the namespace `Lampe.Stdlib`. Note that not every file in the Noir stdlib has a corresponding
file in the Lampe stdlib; this is due to having no relevant extracted definitions.

For example, if you are proving properties of code that needs the definition of `Option<T>` along
with its theorems, you can simply `import Stdlib.Option` and then `open Lampe.Stdlib`
to make them available in your file. This will provide the type definition for `Option<T>` and the
definitions of all relevant functions and methods, along with any theorems.

Methods that are intended to be _internal_ (those that have names starting with `__`) are not
re-exported as they are not intended (by the Noir team) to be relied upon by user code. If you
really do need to prove a theorem involving such a definition, they can be imported directly from
the relevant file in the `std.Extracted` namespace.

## Versioning

Each version of the `lampe` CLI tool works with a single version of the Noir compiler, and so it
extracts with a dependency on the _stdlib version_ that comes with that compiler. The version in
use is recorded in the vendored copy of the standard library at `stdlib/Nargo.toml`.

Unlike other extracted packages—whose Lean names are suffixed with their version—the standard
library is always extracted under the unversioned name `std`. This keeps the stdlib version out of
extracted code and handwritten proofs, so updating Noir does not rename every stdlib reference.

A consequence of this is that a single dependency tree can only contain one extracted standard
library: all packages in the tree must be extracted against the same Noir (and hence stdlib)
version. Attempting to mix extractions pinned to different stdlib versions will fail loudly at
build time, as `lake` will refuse the two conflicting `std` packages.

This restriction is deliberate, as it mirrors how Noir itself works. `nargo` compiles the entire
dependency tree with a single compiler and a single stdlib; a dependency never runs against a
different stdlib version in the actual circuit. An extraction of a library made against an older
Noir version is therefore a snapshot of _different code_ than what `nargo` compiles into your
project, and proofs about that snapshot do not soundly transfer to the artifact you deploy. Mixing
stdlib versions would also provide little in practice even where it built: Noir traits and types
extract to nominal Lean names, so theorems stated against one stdlib version's traits and types
(such as `Eq`, `Ord`, or `Option<T>`) cannot be applied to code using another's. To reuse a
library's proofs in a project on a newer Noir version, re-extract the library against that version
and re-check its proofs.

