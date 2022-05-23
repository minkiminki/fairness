Require ClassicalFacts.
Require FunctionalExtensionality.
(* Require ChoiceFacts. *)
Require Coq.Logic.Epsilon.
(* Require Classical_Prop. *)
Require Logic.Classical_Pred_Type.

Lemma func_ext_dep {A} {B: A -> Type} (f g: forall x, B x): (forall x, f x = g x) -> f = g.
Proof.
  apply @FunctionalExtensionality.functional_extensionality_dep.
Qed.

Lemma func_ext {A B} (f g: A -> B): (forall x, f x = g x) -> f = g.
Proof.
  apply func_ext_dep.
Qed.

Definition classic := Classical_Prop.classic.
Definition inj_pair2 := Classical_Prop.EqdepTheory.inj_pair2.

Definition epsilon_on := ChoiceFacts.EpsilonStatement_on.
Definition epsilon := Epsilon.epsilon.
Lemma epsilon_spec: forall (A : Type) (i : inhabited A) (P : A -> Prop), (exists x : A, P x) -> P (epsilon _ i P).
Proof.
  apply Epsilon.epsilon_spec.
Qed.
