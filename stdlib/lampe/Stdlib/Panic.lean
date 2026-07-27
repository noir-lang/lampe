import std.Extracted
import Lampe

namespace Lampe.Stdlib.Panic

open std

/--
Note that this theorem exists only to make it easy to steps through calls to `panic` in your code as
it cannot (and does not) assert any meaningful properties on the functioning of the call to panic.
-/
theorem panic_correct {p T U msg}
  : STHoare p env ⟦⟧
    («std::panic::panic».call h![T, U] h![msg])
    (fun _ => ⟦⟧) := by
  enter_decl
  steps

