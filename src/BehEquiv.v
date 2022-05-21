From sflib Require Import sflib.
From ITree Require Export ITree.
From Paco Require Import paco.

Export ITreeNotations.

Require Import Coq.Classes.RelationClasses.

From Fairness Require Import ITreeLib.
From Fairness Require Import FairBeh.
From Fairness Require Import SelectBeh.

From Fairness Require Import Axioms.

Set Implicit Arguments.

Section EXTRACT.

  Context {Ident: ID}.

  (** match between raw_tr and tr *)
  Variant _raw_spin
          (raw_spin: forall (R: Type), RawTr.t -> Prop)
          R
    :
    (@RawTr.t _ R) -> Prop :=
    | raw_spin_silent
        (silent: silentE) tl
        (TL: raw_spin _ tl)
      :
      _raw_spin raw_spin (RawTr.cons (inl silent) tl)
  .

  Definition raw_spin: forall (R: Type), RawTr.t -> Prop := paco2 _raw_spin bot2.

  Lemma raw_spin_mon: monotone2 _raw_spin.
  Proof.
    ii. inv IN. econs; eauto.
  Qed.


  Inductive _extract_tr
            (extract_tr: forall (R: Type), RawTr.t -> Tr.t -> Prop)
            R
    :
    (@RawTr.t _ R) -> Tr.t -> Prop :=
  | extract_tr_done
      retv
    :
    _extract_tr extract_tr (RawTr.done retv) (Tr.done retv)
  | extract_tr_spin
      raw
      (RSPIN: raw_spin raw)
    :
    _extract_tr extract_tr raw (Tr.spin)
  | extract_tr_ub
    :
    _extract_tr extract_tr (RawTr.ub) (Tr.ub)
  | extract_tr_nb
    :
    _extract_tr extract_tr (RawTr.nb) (Tr.nb)
  | extract_tr_obs
      (obs: obsE) raw_tl tr_tl
      (TL: extract_tr _ raw_tl tr_tl)
    :
    _extract_tr extract_tr (RawTr.cons (inr obs) raw_tl) (Tr.cons obs tr_tl)
  | extract_tr_silent
      (silent: silentE) raw_tl tr_tl
      (TL: _extract_tr extract_tr raw_tl tr_tl)
    :
    _extract_tr extract_tr (RawTr.cons (inl silent) raw_tl) tr_tl
  .

  Definition extract_tr: forall (R: Type), RawTr.t -> Tr.t -> Prop := paco3 _extract_tr bot3.

  Lemma extract_tr_ind
        (extract_tr : forall R : Type, RawTr.t -> Tr.t -> Prop) (R : Type) (P: RawTr.t -> Tr.t -> Prop)
        (DONE: forall retv : R, P (RawTr.done retv) (Tr.done retv))
        (SPIN: forall (raw : RawTr.t) (RSPIN: raw_spin raw), P raw Tr.spin)
        (UB: P RawTr.ub Tr.ub)
        (NB: P RawTr.nb Tr.nb)
        (OBS: forall (obs : obsE) (raw_tl : RawTr.t) (tr_tl : Tr.t) (TL: extract_tr R raw_tl tr_tl),
            P (RawTr.cons (inr obs) raw_tl) (Tr.cons obs tr_tl))
        (SILENT: forall (silent : silentE) (raw_tl : RawTr.t) (tr_tl : Tr.t)
                   (STEP: _extract_tr extract_tr raw_tl tr_tl) (IH: P raw_tl tr_tl),
            P (RawTr.cons (inl silent) raw_tl) tr_tl)
    :
    forall raw_tr tr, (_extract_tr extract_tr raw_tr tr) -> P raw_tr tr.
  Proof.
    fix IH 3; i.
    inv H; eauto.
  Qed.

  Lemma extract_tr_mon: monotone3 _extract_tr.
  Proof.
    ii. induction IN using extract_tr_ind; econs; eauto.
  Qed.

  Local Hint Constructors _raw_spin.
  Local Hint Unfold raw_spin.
  Local Hint Resolve raw_spin_mon: paco.
  Local Hint Constructors _extract_tr.
  Local Hint Unfold extract_tr.
  Local Hint Resolve extract_tr_mon: paco.

  Lemma extract_tr_ind2
        (R : Type) (P: RawTr.t -> Tr.t -> Prop)
        (DONE: forall retv : R, P (RawTr.done retv) (Tr.done retv))
        (SPIN: forall (raw : RawTr.t) (RSPIN: raw_spin raw), P raw Tr.spin)
        (UB: P RawTr.ub Tr.ub)
        (NB: P RawTr.nb Tr.nb)
        (OBS: forall (obs : obsE) (raw_tl : RawTr.t) (tr_tl : Tr.t) (TL: extract_tr raw_tl tr_tl),
            P (RawTr.cons (inr obs) raw_tl) (Tr.cons obs tr_tl))
        (SILENT: forall (silent : silentE) (raw_tl : RawTr.t) (tr_tl : Tr.t)
                   (STEP: extract_tr raw_tl tr_tl) (IH: P raw_tl tr_tl),
            P (RawTr.cons (inl silent) raw_tl) tr_tl)
    :
    forall raw_tr tr, (extract_tr raw_tr tr) -> P raw_tr tr.
  Proof.
    i. punfold H. induction H using extract_tr_ind; eauto.
    pclearbot. eapply OBS. eauto.
  Qed.

  Variant extract_tr_indC
          (extract_tr: forall (R: Type), RawTr.t -> Tr.t -> Prop)
          R
    :
    (@RawTr.t _ R) -> Tr.t -> Prop :=
    | extract_tr_indC_done
        retv
      :
      extract_tr_indC extract_tr (RawTr.done retv) (Tr.done retv)
    | extract_tr_indC_spin
        raw
        (RSPIN: raw_spin raw)
      :
      extract_tr_indC extract_tr raw (Tr.spin)
    | extract_tr_indC_ub
      :
      extract_tr_indC extract_tr (RawTr.ub) (Tr.ub)
    | extract_tr_indC_nb
      :
      extract_tr_indC extract_tr (RawTr.nb) (Tr.nb)
    | extract_tr_indC_obs
        (obs: obsE) raw_tl tr_tl
        (TL: extract_tr _ raw_tl tr_tl)
      :
      extract_tr_indC extract_tr (RawTr.cons (inr obs) raw_tl) (Tr.cons obs tr_tl)
    | extract_tr_indC_silent
        (silent: silentE) raw_tl tr_tl
        (TL: extract_tr _ raw_tl tr_tl)
      :
      extract_tr_indC extract_tr (RawTr.cons (inl silent) raw_tl) tr_tl
  .

  Lemma extract_tr_indC_mon: monotone3 extract_tr_indC.
  Proof. ii. inv IN; econs; eauto. Qed.

  Local Hint Resolve extract_tr_indC_mon: paco.

  Lemma extract_tr_indC_wrespectful: wrespectful3 _extract_tr extract_tr_indC.
  Proof.
    econs; eauto with paco.
    i. inv PR; eauto.
    { econs; eauto. eapply rclo3_base. eauto. }
    { econs; eauto. eapply extract_tr_mon; eauto. i. eapply rclo3_base. auto. }
  Qed.

  Lemma extract_tr_indC_spec: extract_tr_indC <4= gupaco3 _extract_tr (cpn3 _extract_tr).
  Proof. i. eapply wrespect3_uclo; eauto with paco. eapply extract_tr_indC_wrespectful. Qed.

End EXTRACT.
#[export] Hint Constructors _raw_spin.
#[export] Hint Unfold raw_spin.
#[export] Hint Resolve raw_spin_mon: paco.
#[export] Hint Resolve cpn2_wcompat: paco.
#[export] Hint Constructors _extract_tr.
#[export] Hint Unfold extract_tr.
#[export] Hint Resolve extract_tr_mon: paco.
#[export] Hint Resolve cpn3_wcompat: paco.



Section ExtractTr.

  Context {Ident: ID}.

  Lemma extract_eq_done
        R (tr: @Tr.t R) retv
        (EXTRACT: extract_tr (RawTr.done retv) tr)
    :
    tr = Tr.done retv.
  Proof.
    punfold EXTRACT. inv EXTRACT; eauto. punfold RSPIN. inv RSPIN.
  Qed.

  Lemma extract_eq_ub
        R (tr: @Tr.t R)
        (EXTRACT: extract_tr RawTr.ub tr)
    :
    tr = Tr.ub.
  Proof.
    punfold EXTRACT. inv EXTRACT; eauto. punfold RSPIN. inv RSPIN.
  Qed.

  Lemma extract_eq_nb
        R (tr: @Tr.t R)
        (EXTRACT: extract_tr RawTr.nb tr)
    :
    tr = Tr.nb.
  Proof.
    punfold EXTRACT. inv EXTRACT; eauto. punfold RSPIN. inv RSPIN.
  Qed.



  (** observer of the raw trace **)
  Inductive observe_raw_first
          R
    :
    (@RawTr.t _ R) -> (prod (option obsE) RawTr.t) -> Prop :=
    | observe_raw_first_done
        retv
      :
      observe_raw_first (RawTr.done retv) (None, (RawTr.done retv))
    | observe_raw_first_ub
      :
      observe_raw_first RawTr.ub (None, RawTr.ub)
    | observe_raw_first_nb
      :
      observe_raw_first RawTr.nb (None, RawTr.nb)
    | observe_raw_first_obs
        (obs: obsE) tl
      :
      observe_raw_first (RawTr.cons (inr obs) tl) (Some obs, tl)
    | observe_raw_first_silent
        (silent: silentE) obs tl tl0
        (STEP: observe_raw_first tl (obs, tl0))
      :
      observe_raw_first (RawTr.cons (inl silent) tl) (obs, tl0)
  .

  Definition observe_raw_prop {R}
             (raw: @RawTr.t _ R)
             (obstl: option (prod (option obsE) RawTr.t)): Prop :=
    match obstl with
    | None => raw_spin raw
    | Some obstl0 => observe_raw_first raw obstl0
    end.

  Lemma inhabited_observe_raw R: inhabited (option (prod (option obsE) (@RawTr.t _ R))).
  Proof.
    econs. exact None.
  Qed.

  Definition observe_raw {R} (raw: (@RawTr.t _ R)): option (prod (option obsE) RawTr.t) :=
    epsilon _ (@inhabited_observe_raw R) (observe_raw_prop raw).


  (** properties **)
  (* helper lemmas *)
  Lemma spin_no_obs
        R (raw: @RawTr.t _ R)
        (SPIN: raw_spin raw)
    :
    forall ev tl, ~ observe_raw_first raw (ev, tl).
  Proof.
    ii. revert SPIN. induction H; i; ss; clarify.
    - punfold SPIN. inv SPIN.
    - punfold SPIN. inv SPIN.
    - punfold SPIN. inv SPIN.
    - punfold SPIN. inv SPIN.
    - eapply IHobserve_raw_first; clear IHobserve_raw_first.
      punfold SPIN. inv SPIN. pclearbot. auto.
  Qed.

  Lemma no_obs_spin
        R (raw: @RawTr.t _ R)
        (NOOBS: forall ev tl, ~ observe_raw_first raw (ev, tl))
    :
    raw_spin raw.
  Proof.
    revert_until R. pcofix CIH; i. destruct raw.
    - exfalso. eapply NOOBS. econs.
    - exfalso. eapply NOOBS. econs.
    - exfalso. eapply NOOBS. econs.
    - destruct hd as [silent | obs].
      2:{ exfalso. eapply NOOBS. econs. }
      pfold. econs. right. eapply CIH. ii. eapply NOOBS.
      econs 5. eauto.
  Qed.

  Lemma spin_iff_no_obs
        R (raw: @RawTr.t _ R)
    :
    (raw_spin raw) <-> (forall ev tl, ~ observe_raw_first raw (ev, tl)).
  Proof.
    esplits. split; i. eapply spin_no_obs; eauto. eapply no_obs_spin; eauto.
  Qed.

  Lemma observe_raw_first_inj
        R (raw: @RawTr.t _ R) obstl1 obstl2
        (ORP1: observe_raw_first raw obstl1)
        (ORP2: observe_raw_first raw obstl2)
    :
    obstl1 = obstl2.
  Proof.
    depgen obstl2. induction ORP1; i.
    - inv ORP2; eauto.
    - inv ORP2; eauto.
    - inv ORP2; eauto.
    - inv ORP2; eauto.
    - inv ORP2; eauto.
  Qed.

  Lemma observe_raw_inj
        R (raw: @RawTr.t _ R) obstl1 obstl2
        (ORP1: observe_raw_prop raw obstl1)
        (ORP2: observe_raw_prop raw obstl2)
    :
    obstl1 = obstl2.
  Proof.
    destruct obstl1 as [(obs1, tl1) | ]; ss.
    2:{ destruct obstl2 as [(obs2, tl2) | ]; ss.
        rewrite spin_iff_no_obs in ORP1. eapply ORP1 in ORP2. clarify.
    }
    destruct obstl2 as [(obs2, tl2) | ]; ss.
    2:{ rewrite spin_iff_no_obs in ORP2. eapply ORP2 in ORP1. clarify. }
    f_equal. eapply observe_raw_first_inj; eauto.
  Qed.


  Theorem observe_raw_prop_impl_observe_raw
          R (raw: @RawTr.t _ R) obstl
          (ORP: observe_raw_prop raw obstl)
    :
    observe_raw raw = obstl.
  Proof.
    eapply observe_raw_inj. 2: eauto.
    unfold observe_raw, epsilon. eapply Epsilon.epsilon_spec. eauto.
  Qed.

  Lemma observe_raw_prop_false
        R (raw: @RawTr.t _ R) ev tl
    :
    ~ observe_raw_prop raw (Some (None, RawTr.cons ev tl)).
  Proof.
    ii. ss. remember (None, RawTr.cons ev tl) as obstl. revert Heqobstl. revert ev tl. rename H into ORF.
    induction ORF; i; ss. clarify. eapply IHORF. eauto.
  Qed.

  (** observe_raw reductions **)
  Lemma observe_raw_spin
        R (raw: @RawTr.t _ R)
        (SPIN: raw_spin raw)
    :
    observe_raw raw = None.
  Proof.
    eapply observe_raw_prop_impl_observe_raw. ss.
  Qed.

  Lemma raw_spin_observe
        R (raw: @RawTr.t _ R)
        (NONE: observe_raw raw = None)
    :
    raw_spin raw.
  Proof.
    eapply spin_iff_no_obs. ii.
    assert (SOME: ~ observe_raw raw = Some (ev, tl)).
    { ii. clarify. }
    eapply SOME. eapply observe_raw_prop_impl_observe_raw. ss.
  Qed.

  Lemma observe_raw_done
        R (retv: R)
    :
    observe_raw (RawTr.done retv) = Some (None, RawTr.done retv).
  Proof.
    eapply observe_raw_prop_impl_observe_raw. ss. econs.
  Qed.

  Lemma observe_raw_ub
        R
    :
    observe_raw (R:=R) (RawTr.ub) = Some (None, RawTr.ub).
  Proof.
    eapply observe_raw_prop_impl_observe_raw. ss. econs.
  Qed.

  Lemma observe_raw_nb
        R
    :
    observe_raw (R:=R) (RawTr.nb) = Some (None, RawTr.nb).
  Proof.
    eapply observe_raw_prop_impl_observe_raw. ss. econs.
  Qed.

  Lemma observe_raw_obs
        R obs (tl: @RawTr.t _ R)
    :
    observe_raw (RawTr.cons (inr obs) tl) = Some (Some obs, tl).
  Proof.
    eapply observe_raw_prop_impl_observe_raw. ss. econs.
  Qed.


  Lemma observe_first_some_inj
        R (raw: @RawTr.t _ R) obstl1 obstl2
        (SOME: observe_raw raw = Some obstl1)
        (ORF: observe_raw_first raw obstl2)
    :
    obstl1 = obstl2.
  Proof.
    assert (A: observe_raw_prop raw (Some obstl2)). ss.
    apply observe_raw_prop_impl_observe_raw in A. rewrite SOME in A. clarify.
  Qed.

  Lemma observe_first_some
        R (raw: @RawTr.t _ R) obstl
        (SOME: observe_raw raw = Some obstl)
    :
    observe_raw_first raw obstl.
  Proof.
    assert (NOTSPIN: ~ raw_spin raw).
    { ii. eapply observe_raw_spin in H. clarify. }
    rewrite spin_iff_no_obs in NOTSPIN.
    assert (TEMP: ~ (forall obstl, ~ observe_raw_first raw obstl)).
    { ii. eapply NOTSPIN. i. eauto. }
    eapply Classical_Pred_Type.not_all_not_ex in TEMP. des.
    replace obstl with n; eauto. symmetry. eapply observe_first_some_inj; eauto.
  Qed.

  Theorem observe_raw_spec
          R (raw: @RawTr.t _ R)
    :
    observe_raw_prop raw (observe_raw raw).
  Proof.
    destruct (observe_raw raw) eqn:EQ.
    - ss. eapply observe_first_some; eauto.
    - ss. eapply raw_spin_observe; eauto.
  Qed.

  Lemma observe_raw_silent
        R (tl: @RawTr.t _ R) silent
    :
    observe_raw (RawTr.cons (inl silent) tl) = observe_raw tl.
  Proof.
    eapply observe_raw_prop_impl_observe_raw. destruct (observe_raw tl) eqn:EQ.
    2:{ ss. pfold. econs. left. eapply raw_spin_observe; eauto. }
    ss. destruct p as [obs tl0]. hexploit observe_first_some; eauto. i.
    econs. auto.
  Qed.



  (** raw trace to normal trace **)
  CoFixpoint raw2tr {R} (raw: @RawTr.t _ R): (@Tr.t R) :=
    match observe_raw raw with
    | None => Tr.spin
    | Some (None, RawTr.done retv) => Tr.done retv
    | Some (None, RawTr.ub) => Tr.ub
    | Some (None, RawTr.nb) => Tr.nb
    | Some (None, RawTr.cons _ _) => Tr.ub
    | Some (Some obs, tl) => Tr.cons obs (raw2tr tl)
    end.

  (** reduction lemmas **)
  Lemma raw2tr_red_done
        R (retv: R)
    :
    (raw2tr (RawTr.done retv)) = (Tr.done retv).
  Proof.
    replace (raw2tr (RawTr.done retv)) with (Tr.ob (raw2tr (RawTr.done retv))).
    2:{ symmetry. apply Tr.ob_eq. }
    ss. rewrite observe_raw_done. ss.
  Qed.

  Lemma raw2tr_red_ub
        R
    :
    (raw2tr (R:=R) RawTr.ub) = Tr.ub.
  Proof.
    replace (raw2tr RawTr.ub) with (Tr.ob (R:=R) (raw2tr RawTr.ub)).
    2:{ symmetry. apply Tr.ob_eq. }
    ss. rewrite observe_raw_ub. ss.
  Qed.

  Lemma raw2tr_red_nb
        R
    :
    (raw2tr (R:=R) RawTr.nb) = Tr.nb.
  Proof.
    replace (raw2tr RawTr.nb) with (Tr.ob (R:=R) (raw2tr RawTr.nb)).
    2:{ symmetry. apply Tr.ob_eq. }
    ss. rewrite observe_raw_nb. ss.
  Qed.

  Lemma raw2tr_red_obs
        R obs tl
    :
    (raw2tr (RawTr.cons (inr obs) tl)) = (Tr.cons (R:=R) obs (raw2tr tl)).
  Proof.
    match goal with | |- ?lhs = _ => replace lhs with (Tr.ob lhs) end.
    2:{ symmetry. apply Tr.ob_eq. }
    ss. rewrite observe_raw_obs. ss.
  Qed.

  Lemma raw2tr_red_spin
        R (raw: @RawTr.t _ R)
        (SPIN: raw_spin raw)
    :
    (raw2tr raw) = Tr.spin.
  Proof.
    match goal with | |- ?lhs = _ => replace lhs with (Tr.ob lhs) end.
    2:{ symmetry. apply Tr.ob_eq. }
    ss. rewrite observe_raw_spin; eauto.
  Qed.

  Lemma raw2tr_red_silent
        R silent tl
    :
    (raw2tr (RawTr.cons (inl silent) tl)) = (raw2tr (R:=R) tl).
  Proof.
    match goal with | |- ?lhs = ?rhs => replace lhs with (Tr.ob lhs); [replace rhs with (Tr.ob rhs) |] end.
    2:{ symmetry. apply Tr.ob_eq. }
    2:{ symmetry. apply Tr.ob_eq. }
    ss. rewrite observe_raw_silent. ss.
  Qed.

  Theorem raw2tr_extract
          R (raw: @RawTr.t _ R)
    :
    extract_tr raw (raw2tr raw).
  Proof.
    revert_until R. pcofix CIH. i.
    destruct raw.
    { rewrite raw2tr_red_done. pfold. econs. }
    { rewrite raw2tr_red_ub. pfold. econs. }
    { rewrite raw2tr_red_nb. pfold. econs. }
    destruct hd as [silent | obs].
    2:{ rewrite raw2tr_red_obs. pfold. econs. right. eauto. }
    destruct (observe_raw (RawTr.cons (inl silent) raw)) eqn:EQ.
    2:{ eapply raw_spin_observe in EQ. rewrite raw2tr_red_spin; eauto. }
    rename p into obstl.
    remember (RawTr.cons (inl silent) raw) as raw0. clear Heqraw0. clear silent raw.
    pose (observe_raw_spec) as ORS. specialize (ORS R raw0). rewrite EQ in ORS. ss.
    clear EQ. induction ORS; ss.
    { rewrite raw2tr_red_done. pfold. econs. }
    { rewrite raw2tr_red_ub. pfold. econs. }
    { rewrite raw2tr_red_nb. pfold. econs. }
    { rewrite raw2tr_red_obs. pfold. econs. right. eauto. }
    pfold. econs. punfold IHORS. remember (raw2tr tl) as tr. depgen silent. depgen tl0. revert Heqtr. depgen obs.
    induction IHORS using (@extract_tr_ind); i.
    { rewrite raw2tr_red_silent. rewrite raw2tr_red_done. econs. }
    { exfalso. eapply spin_iff_no_obs in RSPIN. eauto. }
    { rewrite raw2tr_red_silent. rewrite raw2tr_red_ub. econs. }
    { rewrite raw2tr_red_silent. rewrite raw2tr_red_nb. econs. }
    { rewrite raw2tr_red_silent. rewrite raw2tr_red_obs. econs. right. auto. }
    econs 6. rewrite raw2tr_red_silent. eapply IHIHORS; eauto.
    - rewrite raw2tr_red_silent in Heqtr. auto.
    - instantiate (1:=tl0). instantiate (1:=obs). inv ORS. auto.
  Qed.

End ExtractTr.



Section ExtractRaw.

  Context {Ident: ID}.
  Variable wf: WF.
  Variable wf0: T wf.
  Variable R: Type.
  Variable r0: R.

  Definition st_tr_im := ((@state _ R) * (@Tr.t R) * (imap wf))%type.

  (** observer of the state, needs trace for obs return value information **)
  Inductive observe_state_trace
    :
    st_tr_im -> (prod (list rawE) st_tr_im) -> Prop :=
  | observe_state_trace_ret
      (retv: R) im
    :
    observe_state_trace (Ret retv, Tr.done retv, im)
                        ([], (Ret retv, Tr.done retv, im))
  | observe_state_trace_obs
      fn args ktr rv tl im
    :
    observe_state_trace (Vis (Observe fn args) ktr, Tr.cons (obsE_syscall fn args rv) tl, im)
                        ([inr (obsE_syscall fn args rv)], (ktr rv, tl, im))
  | observe_state_trace_tau
      itr tr im evs sti
      (NNB: tr <> Tr.nb)
      (SPIN: tr = Tr.spin -> (Beh.diverge_index im itr /\ evs = [] /\ sti = (itr, tr, im)))
      (* (CONT: tr <> Tr.spin -> (observe_state_trace (itr, tr, im) (evs, sti) /\ Beh.of_state im itr tr)) *)
      (CONT: tr <> Tr.spin -> observe_state_trace (itr, tr, im) (evs, sti))
      (CONT: tr <> Tr.spin -> Beh.of_state im itr tr)
    :
    observe_state_trace (Tau itr, tr, im)
                        ((inl silentE_tau) :: evs, sti)
  | observe_state_trace_choose
      X ktr x tr im evs sti
      (NNB: tr <> Tr.nb)
      (SPIN: tr = Tr.spin -> (Beh.diverge_index im (ktr x) /\ evs = [] /\ sti = (ktr x, tr, im)))
      (* (CONT: tr <> Tr.spin -> (observe_state_trace (ktr x, tr, im) (evs, sti) /\ Beh.of_state im (ktr x) tr)) *)
      (CONT: tr <> Tr.spin -> observe_state_trace (ktr x, tr, im) (evs, sti))
      (BEH: tr <> Tr.spin -> Beh.of_state im (ktr x) tr)
    :
    observe_state_trace (Vis (Choose X) ktr, tr, im)
                        ((inl silentE_tau) :: evs, sti)
  | observe_state_trace_fair
      fm ktr tr im evs sti im0
      (NNB: tr <> Tr.nb)
      (SPIN: tr = Tr.spin -> (Beh.diverge_index im0 (ktr tt) /\ evs = [] /\ sti = (ktr tt, tr, im0)))
      (* (CONT: tr <> Tr.spin -> (observe_state_trace (ktr tt, tr, im0) (evs, sti) /\ Beh.of_state im0 (ktr tt) tr)) *)
      (CONT: tr <> Tr.spin -> observe_state_trace (ktr tt, tr, im0) (evs, sti))
      (CONT: tr <> Tr.spin -> Beh.of_state im0 (ktr tt) tr)
      (FAIR: fair_update im im0 fm)
    :
    observe_state_trace (Vis (Fair fm) ktr, tr, im)
                        ((inl (silentE_fair fm)) :: evs, sti)
  | observe_state_trace_ub
      ktr tr im
    :
    observe_state_trace (Vis Undefined ktr, tr, im)
                        ([], (Vis Undefined ktr, tr, im))
  | observe_state_trace_nb
      itr im
    :
    observe_state_trace (itr, Tr.nb, im)
                        ([], (itr, Tr.nb, im))
  .


  Definition observe_state_prop (sti: st_tr_im) (rawsti: (prod (list rawE) st_tr_im)): Prop :=
    (let '(st, tr, im) := sti in (Beh.of_state im st tr)) -> observe_state_trace sti rawsti.
  (* (<<WF: wf_tr sttr>>) -> (observe_state_trace sttr rawst). *)

  Lemma inhabited_observe_state: inhabited (prod (list rawE) st_tr_im).
  Proof.
    econs. econs. exact []. econs. econs. exact (Ret r0). exact (Tr.done r0). exact (fun _ => wf0).
  Qed.

  Definition observe_state (sti: st_tr_im): (prod (list rawE) st_tr_im) :=
    epsilon _ inhabited_observe_state (observe_state_prop sti).


  (** properties **)
  Lemma beh_implies_spin
        (im: imap wf) (st: @state _ R)
        (BEH: Beh.of_state im st Tr.spin)
    :
    Beh.diverge_index im st.
  Proof.
    revert_until R. pcofix CIH; i. remember Tr.spin as tr. revert Heqtr.
    induction BEH using (@Beh.of_state_ind2); i; clarify; ss; eauto.
    { eapply paco3_mon; eauto. ss. }
    { pfold. econs. right. eauto. }
    { pfold. econs. right. eauto. }
    { pfold. econs. right. eauto. eauto. }
  Qed.

  Lemma observe_state_trace_exists
        (st: @state _ R) (tr: Tr.t) (im: imap wf)
        (BEH: Beh.of_state im st tr)
    :
    exists rawsti, observe_state_trace (st, tr, im) rawsti.
  Proof.
    induction BEH using (@Beh.of_state_ind2).
    - eexists. econs.
    - punfold H. inv H.
      + pclearbot. eexists. econs; i; ss; eauto.
      + pclearbot. eexists. econs; i; ss; eauto.
      + pclearbot. eexists. econs; i; ss; eauto.
      + pclearbot. eexists. econs; i; ss; eauto.
    - eexists. econs.
    - eexists. econs.
    - destruct (classic (tr = Tr.nb)) as [NB | NNB]; clarify; ss.
      + eexists. econs 7.
      + destruct (classic (tr = Tr.spin)) as [SPIN | NSPIN]; clarify; ss.
        * des. eexists. econs; i; ss; clarify. splits; eauto. eapply beh_implies_spin; eauto.
        * des. destruct rawsti. eexists. econs; i; ss; clarify; eauto.
    - destruct (classic (tr = Tr.nb)) as [NB | NNB]; clarify; ss.
      + eexists. econs 7.
      + destruct (classic (tr = Tr.spin)) as [SPIN | NSPIN]; clarify; ss.
        * des. eexists. econs; i; ss; clarify. splits; eauto. eapply beh_implies_spin; eauto.
        * des. destruct rawsti. rr in IHBEH. eexists. econs; i; ss; clarify; eauto.
    - destruct (classic (tr = Tr.nb)) as [NB | NNB]; clarify; ss.
      + eexists. econs 7.
      + destruct (classic (tr = Tr.spin)) as [SPIN | NSPIN]; clarify; ss.
        * des. eexists. econs; i; ss; clarify. splits; eauto. eapply beh_implies_spin; eauto. eauto.
        * des. destruct rawsti. rr in IHBEH. eexists. econs; i; ss; clarify; eauto.
    - eexists. econs; eauto.
  Qed.

  Lemma observe_state_exists
        (st: @state _ R) (tr: Tr.t) (im: imap wf)
    :
    exists rawsti, observe_state_prop (st, tr, im) rawsti.
  Proof.
    destruct (classic (Beh.of_state im st tr)) as [BEH | NBEH].
    - hexploit observe_state_trace_exists; eauto. i. des. eexists. ii. eauto.
    - eexists. ii. clarify.
      Unshelve. exact ([], (Ret r0, Tr.done r0, fun _ => wf0)).
  Qed.

  (** (state, trace, imap) to raw trace **)
  CoFixpoint raw_spin_trace: RawTr.t :=
    @RawTr.cons _ R (inl silentE_tau) raw_spin_trace.

  CoFixpoint _sti2raw (evs: list rawE) (sti: st_tr_im): (@RawTr.t _ R) :=
    match evs with
    | hd :: tl => RawTr.cons hd (_sti2raw tl sti)
    | [] =>
        match observe_state sti with
        | (evs, (Ret _, Tr.done retv, _)) => RawTr.app evs (RawTr.done retv)
        | (evs, (_, Tr.nb, _)) => RawTr.app evs RawTr.nb
        | (evs, (Vis Undefined _, Tr.spin, _)) => RawTr.app evs raw_spin_trace
        | (evs, (Vis Undefined _, _, _)) => RawTr.app evs RawTr.ub
        | (hd :: tl, sti0) => RawTr.cons hd (_sti2raw tl sti0)
        | (evs, _) => RawTr.app evs RawTr.ub
        end
    end.

  Definition sti2raw (sti: st_tr_im): (@RawTr.t _ R) := _sti2raw [] sti.


  (** observe_state reduction lemmas **)
  Lemma observe_state_ret
        (im: imap wf) (retv: R)
    :
    observe_state (Ret retv, Tr.done retv, im) = ([], (Ret retv, Tr.done retv, im)).
  Proof.
    unfold observe_state, epsilon. unfold Epsilon.epsilon. unfold proj1_sig. des_ifs.
    rename x into rawsti. clear Heq.
    hexploit (observe_state_exists). intros OSP. eapply o in OSP; clear o.
    unfold observe_state_prop in OSP. hexploit OSP; clear OSP; eauto.
    i. inv H. eauto.
  Qed.

  Lemma observe_state_obs
        (im: imap wf) fn args rv tl ktr
        (BEH: Beh.of_state im (ktr rv) tl)
    :
    observe_state (Vis (Observe fn args) ktr, Tr.cons (obsE_syscall fn args rv) tl, im) =
      ([inr (obsE_syscall fn args rv)], (ktr rv, tl, im)).
  Proof.
    unfold observe_state, epsilon. unfold Epsilon.epsilon. unfold proj1_sig. des_ifs.
    rename x into rawsti. clear Heq.
    hexploit (observe_state_exists). intros OSP. eapply o in OSP; clear o.
    unfold observe_state_prop in OSP. hexploit OSP; clear OSP; eauto.
    { pfold. econs. eauto. }
    i. inv H. eapply inj_pair2 in H3. clarify.
  Qed.

  Lemma observe_state_tau
        (im: imap wf) itr tr
        (BEH: Beh.of_state im (Tau itr) tr)
        (NNB: tr <> Tr.nb)
        (NSPIN: tr <> Tr.spin)
    :
    (Beh.of_state im itr tr) /\
      (exists evs sti, (observe_state_trace (itr, tr, im) (evs, sti)) /\
                    (observe_state (Tau itr, tr, im) = ((inl silentE_tau) :: evs, sti))).
  Proof.
    unfold observe_state, epsilon. unfold Epsilon.epsilon. unfold proj1_sig. des_ifs.
    rename x into rawsttr. clear Heq.
    hexploit (observe_state_exists). intros OSP. eapply o in OSP; clear o.
    unfold observe_state_prop in OSP. hexploit OSP; clear OSP; eauto.
    i. inv H; ss; eauto. hexploit CONT; eauto; i. des. esplits; eauto.
  Qed.

  Lemma observe_state_tau_spin
        (im: imap wf) itr tr
        (BEH: Beh.of_state im (Tau itr) tr)
        (NNB: tr <> Tr.nb)
        (SPIN: tr = Tr.spin)
    :
    (Beh.diverge_index im itr) /\
      observe_state (Tau itr, tr, im) = ([inl silentE_tau], (itr, tr, im)).
  Proof.
    unfold observe_state, epsilon. unfold Epsilon.epsilon. unfold proj1_sig. des_ifs.
    rename x into rawsttr. clear Heq.
    hexploit (observe_state_exists). intros OSP. eapply o in OSP; clear o.
    unfold observe_state_prop in OSP. hexploit OSP; clear OSP; eauto.
    i. inv H; ss; eauto. hexploit SPIN; ss; i. des; clarify.
  Qed.

  Lemma observe_state_choose
        (im: imap wf) tr X ktr
        (BEH: Beh.of_state im (Vis (Choose X) ktr) tr)
        (NNB: tr <> Tr.nb)
        (NSPIN: tr <> Tr.spin)
    :
    exists (x: X),
      (Beh.of_state im (ktr x) tr) /\
        (exists evs sti,
            (observe_state_trace (ktr x, tr, im) (evs, sti)) /\
              (observe_state (Vis (Choose X) ktr, tr, im) = ((inl silentE_tau) :: evs, sti))).
  Proof.
    unfold observe_state, epsilon. unfold Epsilon.epsilon. unfold proj1_sig. des_ifs.
    rename x into rawsttr. clear Heq.
    hexploit (observe_state_exists). intros OSP. eapply o in OSP; clear o.
    unfold observe_state_prop in OSP. hexploit OSP; clear OSP; eauto.
    i. inv H; clarify. eapply inj_pair2 in H0. clarify. hexploit CONT; eauto; i. des. esplits; eauto.
  Qed.

  Lemma observe_state_choose_spin
        (im: imap wf) tr X ktr
        (BEH: Beh.of_state im (Vis (Choose X) ktr) tr)
        (NNB: tr <> Tr.nb)
        (SPIN: tr = Tr.spin)
    :
    exists (x: X),
      (Beh.diverge_index im (ktr x)) /\
        (observe_state (Vis (Choose X) ktr, tr, im) = ([inl silentE_tau], (ktr x, tr, im))).
  Proof.
    unfold observe_state, epsilon. unfold Epsilon.epsilon. unfold proj1_sig. des_ifs.
    rename x into rawsttr. clear Heq.
    hexploit (observe_state_exists). intros OSP. eapply o in OSP; clear o.
    unfold observe_state_prop in OSP. hexploit OSP; clear OSP; eauto.
    i. inv H; clarify. eapply inj_pair2 in H0. clarify. hexploit SPIN; eauto; i. des. clarify. eauto.
  Qed.

  Lemma observe_state_fair
        (im: imap wf) tr fm ktr
        (BEH: Beh.of_state im (Vis (Fair fm) ktr) tr)
        (NNB: tr <> Tr.nb)
        (NSPIN: tr <> Tr.spin)
    :
    exists (im0: imap wf),
      (fair_update im im0 fm) /\ (Beh.of_state im0 (ktr tt) tr) /\
        (exists evs sti,
            (observe_state_trace (ktr tt, tr, im0) (evs, sti)) /\
              (observe_state (Vis (Fair fm) ktr, tr, im) = ((inl (silentE_fair fm)) :: evs, sti))).
  Proof.
    unfold observe_state, epsilon. unfold Epsilon.epsilon. unfold proj1_sig. des_ifs.
    rename x into rawsttr. clear Heq.
    hexploit (observe_state_exists). intros OSP. eapply o in OSP; clear o.
    unfold observe_state_prop in OSP. hexploit OSP; clear OSP; eauto.
    i. inv H; ss; eauto. eapply inj_pair2 in H2. clarify. hexploit CONT; eauto; i. des. esplits; eauto.
  Qed.

  Lemma observe_state_fair_spin
        (im: imap wf) tr fm ktr
        (BEH: Beh.of_state im (Vis (Fair fm) ktr) tr)
        (NNB: tr <> Tr.nb)
        (NSPIN: tr = Tr.spin)
    :
    exists (im0: imap wf),
      (fair_update im im0 fm) /\
        (Beh.diverge_index im0 (ktr tt)) /\
        (observe_state (Vis (Fair fm) ktr, tr, im) = ([inl (silentE_fair fm)], (ktr tt, tr, im0))).
  Proof.
    unfold observe_state, epsilon. unfold Epsilon.epsilon. unfold proj1_sig. des_ifs.
    rename x into rawsttr. clear Heq.
    hexploit (observe_state_exists). intros OSP. eapply o in OSP; clear o.
    unfold observe_state_prop in OSP. hexploit OSP; clear OSP; eauto.
    i. inv H; ss; eauto. eapply inj_pair2 in H2. clarify. hexploit SPIN; eauto; i. des. clarify. esplits; eauto.
  Qed.

  Lemma observe_state_ub
        (im: imap wf) tr ktr
    :
    observe_state (Vis Undefined ktr, tr, im) = ([], (Vis Undefined ktr, tr, im)).
  Proof.
    unfold observe_state, epsilon. unfold Epsilon.epsilon. unfold proj1_sig. des_ifs.
    rename x into rawsttr. clear Heq.
    hexploit (observe_state_exists). intros OSP. eapply o in OSP; clear o.
    unfold observe_state_prop in OSP. hexploit OSP; clear OSP; eauto.
    i. inv H; eauto. eapply inj_pair2 in H1. clarify.
  Qed.

  Lemma observe_state_nb
        (im: imap wf) itr
    :
    observe_state (itr, Tr.nb, im) = ([], (itr, Tr.nb, im)).
  Proof.
    unfold observe_state, epsilon. unfold Epsilon.epsilon. unfold proj1_sig. des_ifs.
    rename x into rawsttr. clear Heq.
    hexploit (observe_state_exists). intros OSP. eapply o in OSP; clear o.
    unfold observe_state_prop in OSP. hexploit OSP; clear OSP; eauto.
    i. inv H; clarify.
  Qed.

  Lemma observe_state_spin_div
        (im: imap wf) itr
        (DIV: @Beh.diverge_index _ _ R im itr)
    :
    observe_state_trace (itr, Tr.spin, im) (observe_state (itr, Tr.spin, im)).
  Proof.
    punfold DIV. inv DIV.
    - pclearbot. hexploit observe_state_tau_spin; ss. 2:ss.
      2:{ i. des. setoid_rewrite H0; clear H0. econs; ss. }
      pfold. econs; eauto. pfold. econs; eauto.
    - pclearbot. hexploit observe_state_choose_spin; ss. 2: ss.
      2:{ i. des. setoid_rewrite H0; clear H0. econs; eauto; ss. }
      pfold. econs; eauto. pfold. econs; eauto.
    - pclearbot. hexploit observe_state_fair_spin; ss. 2: ss.
      2:{ i. des. setoid_rewrite H1; clear H1. econs; eauto; ss. }
      pfold. econs; eauto. pfold. econs; eauto.
    - rewrite observe_state_ub. econs; eauto.
  Qed.

  Lemma observe_state_spin
        (im: imap wf) itr
        (BEH: @Beh.of_state _ _ R im itr Tr.spin)
    :
    observe_state_trace (itr, Tr.spin, im) (observe_state (itr, Tr.spin, im)).
  Proof.
    remember Tr.spin as tr. revert Heqtr. induction BEH using @Beh.of_state_ind2; i; ss.
    - eapply observe_state_spin_div; eauto.
    - clarify. hexploit observe_state_tau_spin; ss. 2: ss.
      2:{ i. des. setoid_rewrite H0; clear H0. econs; ss. }
      pfold. econs 5. punfold BEH.
    - clarify. hexploit observe_state_choose_spin; ss. 2: ss.
      2:{ i. des. setoid_rewrite H0; clear H0. econs; ss. i. splits; eauto. }
      pfold. econs 6. punfold BEH.
    - clarify. hexploit observe_state_fair_spin; ss. 2: ss.
      2:{ i. des. setoid_rewrite H1; clear H1. econs; ss; eauto. }
      pfold. econs 7; eauto. punfold BEH.
    - clarify. rewrite observe_state_ub. econs.
  Qed.

  Theorem observe_state_spec
          (sti: st_tr_im)
    :
    observe_state_prop sti (observe_state sti).
  Proof.
    destruct sti as [[st tr] im]. ii. rename H into BEH.
    ides st.
    - punfold BEH. inv BEH.
      + rewrite observe_state_ret. econs.
      + punfold SPIN. inv SPIN.
      + rewrite observe_state_nb. econs.
    - destruct (classic (tr = Tr.nb)) as [NB | NNB]; clarify.
      { rewrite observe_state_nb. econs. }
      destruct (classic (tr = Tr.spin)) as [SPIN | NSPIN]; clarify.
      { eapply observe_state_spin; eauto. }
      hexploit observe_state_tau; ss.
      4:{ i; des. setoid_rewrite H1; clear H1. econs; ss. }
      all: eauto.
    - destruct e.
      + destruct (classic (tr = Tr.nb)) as [NB | NNB]; clarify.
        { rewrite observe_state_nb. econs. }
        destruct (classic (tr = Tr.spin)) as [SPIN | NSPIN]; clarify.
        { eapply observe_state_spin; eauto. }
        hexploit observe_state_choose; ss.
        4:{ i; des. setoid_rewrite H1; clear H1. econs; ss. all: eauto. }
        all: eauto.
      + destruct (classic (tr = Tr.nb)) as [NB | NNB]; clarify.
        { rewrite observe_state_nb. econs. }
        destruct (classic (tr = Tr.spin)) as [SPIN | NSPIN]; clarify.
        { eapply observe_state_spin; eauto. }
        hexploit observe_state_fair; ss.
        4:{ i; des. setoid_rewrite H2; clear H2. econs; ss. all: eauto. }
        all: eauto.
      + destruct (classic (tr = Tr.nb)) as [NB | NNB]; clarify.
        { rewrite observe_state_nb. econs. }
        destruct (classic (tr = Tr.spin)) as [SPIN | NSPIN]; clarify.
        { eapply observe_state_spin; eauto. }
        punfold BEH. inv BEH; ss. eapply inj_pair2 in H3. clarify. pclearbot.
        rewrite observe_state_obs; eauto. econs.
      + rewrite observe_state_ub. econs.
  Qed.

  Lemma observe_state_trace_preserves
        st0 tr0 im0 evs st1 tr1 im1
        (BEH: Beh.of_state im0 st0 tr0)
        (OST: observe_state_trace (st0, tr0, im0) (evs, (st1, tr1, im1)))
    :
    Beh.of_state im1 st1 tr1.
  Proof.
    remember (st0, tr0, im0) as sti0. remember (evs, (st1, tr1, im1)) as esti1.
    move OST before r0. revert_until OST.
    induction OST; i; ss; clarify.
    { punfold BEH. inv BEH. eapply inj_pair2 in H3. clarify. pclearbot. eauto. }
    { destruct (classic (tr0 = Tr.spin)) as [TRS | TRNS]; clarify.
      { hexploit SPIN; eauto. i; des; clarify. pfold. econs. eauto. }
      eapply H. ss. 2,3: eauto. eauto.
    }
    { destruct (classic (tr0 = Tr.spin)) as [TRS | TRNS]; clarify.
      { hexploit SPIN; eauto. i; des; clarify. pfold. econs. eauto. }
      eapply H. ss. 2,3: eauto. eauto.
    }
    { destruct (classic (tr0 = Tr.spin)) as [TRS | TRNS]; clarify.
      { hexploit SPIN; eauto. i; des; clarify. pfold. econs. eauto. }
      eapply H. ss. 2,3: eauto. eauto.
    }
  Qed.

  (* Definition wf_evs (evs: list rawE): Prop := *)
  (*   (List.Forall is_tau evs) \/ *)
  (*     (exists taus obs, (evs = taus ++ [inr obs]) /\ (List.Forall is_tau taus)). *)

  Inductive wf_evs: (list rawE) -> Prop :=
  | wf_evs_nil
    :
    wf_evs []
  | wf_evs_tau
      ev tl
      (WF: wf_evs tl)
    :
    wf_evs ((inl ev) :: tl)
  | wf_evs_obs
      obs
    :
    wf_evs [inr obs]
  .

  Local Hint Constructors wf_evs. 

  Lemma observe_state_trace_wf_evs
        sti raws sti0
        (OST: observe_state_trace sti (raws, sti0))
    :
    wf_evs raws.
  Proof.
    remember (raws, sti0) as rsti. move OST before r0. revert_until OST.
    induction OST; i; ss; clarify; eauto.
    { destruct (classic (tr = Tr.spin)) as [TRS | TRNS]; clarify.
      { hexploit SPIN; ss; i; des. clarify. econs. eauto. }
      econs. eapply H; eauto. }
    { destruct (classic (tr = Tr.spin)) as [TRS | TRNS]; clarify.
      { hexploit SPIN; ss; i; des. clarify. econs. eauto. }
      econs. eapply H; eauto. }
    { destruct (classic (tr = Tr.spin)) as [TRS | TRNS]; clarify.
      { hexploit SPIN; ss; i; des. clarify. econs. eauto. }
      econs. eapply H; eauto. }
  Qed.


  (** sti2raw reduction lemmas **)
  Lemma _sti2raw_red_evs
        (evs: list rawE) (sti: st_tr_im)
    :
    _sti2raw evs sti = RawTr.app evs (sti2raw sti).
  Proof.
    revert sti. induction evs; i. ss.
    match goal with | |- ?lhs = _ => replace lhs with (RawTr.ob lhs) end.
    2:{ symmetry. apply RawTr.ob_eq. }
    ss. f_equal. eauto.
  Qed.

  Lemma sti2raw_red_ret
        (im: imap wf) (retv: R)
    :
    sti2raw (Ret retv, Tr.done retv, im) = RawTr.done retv.
  Proof.
    match goal with | |- ?lhs = _ => replace lhs with (RawTr.ob lhs) end.
    2:{ symmetry. apply RawTr.ob_eq. }
    ss. rewrite observe_state_ret. ss.
  Qed.

  Lemma sti2raw_red_nb
        (im: imap wf) (st: @state _ R)
    :
    sti2raw (st, Tr.nb, im) = RawTr.nb.
  Proof.
    match goal with | |- ?lhs = _ => replace lhs with (RawTr.ob lhs) end.
    2:{ symmetry. apply RawTr.ob_eq. }
    ss. rewrite observe_state_nb. ss. des_ifs.
  Qed.

  Lemma sti2raw_red_ub
        (im: imap wf) ktr tr
        (NNB: tr <> Tr.nb)
        (NSPIN: tr <> Tr.spin)
    :
    sti2raw (Vis Undefined ktr, tr, im) = RawTr.ub.
  Proof.
    match goal with | |- ?lhs = _ => replace lhs with (RawTr.ob lhs) end.
    2:{ symmetry. apply RawTr.ob_eq. }
    ss. rewrite observe_state_ub. ss. des_ifs.
  Qed.

  Lemma sti2raw_red_ub_spin
        (im: imap wf) ktr tr
        (NNB: tr <> Tr.nb)
        (NSPIN: tr = Tr.spin)
    :
    sti2raw (Vis Undefined ktr, tr, im) = raw_spin_trace.
  Proof.
    match goal with | |- ?lhs = _ => replace lhs with (RawTr.ob lhs) end.
    2:{ symmetry. apply RawTr.ob_eq. }
    ss. rewrite observe_state_ub. ss. des_ifs.
  Qed.

  Ltac ireplace H := symmetry in H; apply simpobs in H; apply bisim_is_eq in H; rewrite H; clarify.

  Lemma sti2raw_red_aux
        st0 tr0 im0 ev evs
        (BEH: Beh.of_state im0 st0 tr0)
    :
    match
      match _observe st0 with
      | RetF _ =>
          match tr0 with
          | Tr.done retv => RawTr.cons ev (RawTr.app evs (RawTr.done retv))
          | Tr.nb => RawTr.cons ev (RawTr.app evs RawTr.nb)
          | _ => RawTr.cons ev (_sti2raw evs (st0, tr0, im0))
          end
      | VisF Undefined _ =>
          match tr0 with
          | Tr.spin => RawTr.cons ev (RawTr.app evs raw_spin_trace)
          | Tr.nb => RawTr.cons ev (RawTr.app evs RawTr.nb)
          | _ => RawTr.cons ev (RawTr.app evs RawTr.ub)
          end
      | _ =>
          match tr0 with
          | Tr.nb => RawTr.cons ev (RawTr.app evs RawTr.nb)
          | _ => RawTr.cons ev (_sti2raw evs (st0, tr0, im0))
          end
      end
    with
    | RawTr.done retv => RawTr.done retv
    | RawTr.ub => RawTr.ub
    | RawTr.nb => RawTr.nb
    | RawTr.cons ev tl => RawTr.cons ev tl
    end = RawTr.cons ev (RawTr.app evs (sti2raw (st0, tr0, im0))).
  Proof.
    destruct (_observe st0) eqn:EQ.
    - ireplace EQ. destruct tr0 eqn:TR; ss; clarify.
      + punfold BEH. inv BEH. rewrite sti2raw_red_ret. ss.
      + punfold BEH. inv BEH. punfold SPIN. inv SPIN.
      + punfold BEH. inv BEH.
      + rewrite sti2raw_red_nb. ss.
      + punfold BEH. inv BEH.
    - ireplace EQ. destruct tr0 eqn:TR; ss; clarify.
      + rewrite _sti2raw_red_evs. ss.
      + rewrite _sti2raw_red_evs. ss.
      + rewrite _sti2raw_red_evs. ss.
      + rewrite sti2raw_red_nb. ss.
      + rewrite _sti2raw_red_evs. ss.
    - ireplace EQ. destruct e eqn:EV; ss; clarify.
      { destruct tr0 eqn:TR; ss; clarify.
        - rewrite _sti2raw_red_evs. ss.
        - rewrite _sti2raw_red_evs. ss.
        - rewrite _sti2raw_red_evs. ss.
        - rewrite sti2raw_red_nb. ss.
        - rewrite _sti2raw_red_evs. ss.
      }
      { destruct tr0 eqn:TR; ss; clarify.
        - rewrite _sti2raw_red_evs. ss.
        - rewrite _sti2raw_red_evs. ss.
        - rewrite _sti2raw_red_evs. ss.
        - rewrite sti2raw_red_nb. ss.
        - rewrite _sti2raw_red_evs. ss.
      }
      { destruct tr0 eqn:TR; ss; clarify.
        - rewrite _sti2raw_red_evs. ss.
        - rewrite _sti2raw_red_evs. ss.
        - rewrite _sti2raw_red_evs. ss.
        - rewrite sti2raw_red_nb. ss.
        - rewrite _sti2raw_red_evs. ss.
      }
      { destruct tr0 eqn:TR; ss; clarify.
        - rewrite sti2raw_red_ub; ss.
        - rewrite sti2raw_red_ub_spin; ss.
        - rewrite sti2raw_red_ub; ss.
        - rewrite sti2raw_red_nb. ss.
        - rewrite sti2raw_red_ub; ss.
      }
  Qed.

  Lemma sti2raw_red_aux2
        st0 tr0 im0 ev
        (BEH: Beh.of_state im0 st0 tr0)
    :
    match
      match _observe st0 with
      | RetF _ =>
          match tr0 with
          | Tr.done retv => RawTr.cons ev (RawTr.done retv)
          | Tr.nb => RawTr.cons ev RawTr.nb
          | _ => RawTr.cons ev (sti2raw (st0, tr0, im0))
          end
      | VisF Undefined _ =>
          match tr0 with
          | Tr.spin => RawTr.cons ev raw_spin_trace
          | Tr.nb => RawTr.cons ev RawTr.nb
          | _ => RawTr.cons ev RawTr.ub
          end
      | _ =>
          match tr0 with
          | Tr.nb => RawTr.cons ev RawTr.nb
          | _ => RawTr.cons ev (sti2raw (st0, tr0, im0))
          end
      end
    with
    | RawTr.done retv => RawTr.done retv
    | RawTr.ub => RawTr.ub
    | RawTr.nb => RawTr.nb
    | RawTr.cons ev tl => RawTr.cons ev tl
    end = RawTr.cons ev (sti2raw (st0, tr0, im0)).
  Proof.
    hexploit sti2raw_red_aux; eauto. i. instantiate (1:=[]) in H. ss. eauto.
  Qed.

  Lemma sti2raw_red_obs
        (im: imap wf) fn args rv tl ktr
        (BEH: Beh.of_state im (ktr rv) tl)
    :
    sti2raw (Vis (Observe fn args) ktr, Tr.cons (obsE_syscall fn args rv) tl, im) =
      RawTr.cons (inr (obsE_syscall fn args rv)) (sti2raw (ktr rv, tl, im)).
  Proof.
    match goal with | |- ?lhs = _ => replace lhs with (RawTr.ob lhs) end.
    2:{ symmetry. apply RawTr.ob_eq. }
    ss. rewrite observe_state_obs; eauto.
    eapply sti2raw_red_aux; eauto.
  Qed.

  Lemma sti2raw_red_tau
        (im: imap wf) itr tr
        (BEH: Beh.of_state im (Tau itr) tr)
        (NNB: tr <> Tr.nb)
        (NSPIN: tr <> Tr.spin)
    :
    (Beh.of_state im itr tr) /\
      exists evs sti,
        observe_state_trace (itr, tr, im) (evs, sti) /\
          (sti2raw (Tau itr, tr, im) =
             RawTr.app ((inl silentE_tau) :: evs) (sti2raw sti)).
  Proof.
    hexploit observe_state_tau; eauto. i. des. split; eauto. esplits; eauto.
    match goal with | |- ?lhs = _ => replace lhs with (RawTr.ob lhs) end.
    2:{ symmetry. apply RawTr.ob_eq. }
    ss. rewrite H1; clear H1. destruct sti as [[st0 tr0] im0].
    ss. eapply sti2raw_red_aux. eapply observe_state_trace_preserves; eauto.
  Qed.

  Lemma sti2raw_red_tau_spin
        (im: imap wf) itr tr
        (BEH: Beh.of_state im (Tau itr) tr)
        (NNB: tr <> Tr.nb)
        (SPIN: tr = Tr.spin)
    :
    (Beh.diverge_index im itr) /\
      (sti2raw (Tau itr, tr, im) =
         RawTr.cons (inl silentE_tau) (sti2raw (itr, tr, im))).
  Proof.
    hexploit observe_state_tau_spin; eauto. i. des. split; eauto.
    match goal with | |- ?lhs = _ => replace lhs with (RawTr.ob lhs) end.
    2:{ symmetry. apply RawTr.ob_eq. }
    ss. rewrite H0; clear H0.
    ss. eapply sti2raw_red_aux2. clarify. pfold. econs. eauto.
  Qed.

  Lemma sti2raw_red_choose
        (im: imap wf) tr X ktr
        (BEH: Beh.of_state im (Vis (Choose X) ktr) tr)
        (NNB: tr <> Tr.nb)
        (NSPIN: tr <> Tr.spin)
    :
    exists x,
      (Beh.of_state im (ktr x) tr) /\
        exists evs sti,
          observe_state_trace (ktr x, tr, im) (evs, sti) /\
            (sti2raw (Vis (Choose X) ktr, tr, im) =
               RawTr.app ((inl silentE_tau) :: evs) (sti2raw sti)).
  Proof.
    hexploit observe_state_choose; eauto. i. des. esplits; eauto.
    match goal with | |- ?lhs = _ => replace lhs with (RawTr.ob lhs) end.
    2:{ symmetry. apply RawTr.ob_eq. }
    ss. rewrite H1; clear H1. destruct sti as [[st0 tr0] im0].
    ss. eapply sti2raw_red_aux. eapply observe_state_trace_preserves; eauto.
  Qed.

  Lemma sti2raw_red_choose_spin
        (im: imap wf) tr X ktr
        (BEH: Beh.of_state im (Vis (Choose X) ktr) tr)
        (NNB: tr <> Tr.nb)
        (SPIN: tr = Tr.spin)
    :
    exists x,
      (Beh.diverge_index im (ktr x)) /\
        (sti2raw (Vis (Choose X) ktr, tr, im) =
           RawTr.cons (inl silentE_tau) (sti2raw (ktr x, tr, im))).
  Proof.
    hexploit observe_state_choose_spin; eauto. i. des. esplits; eauto.
    match goal with | |- ?lhs = _ => replace lhs with (RawTr.ob lhs) end.
    2:{ symmetry. apply RawTr.ob_eq. }
    ss. rewrite H0; clear H0.
    ss. eapply sti2raw_red_aux2. clarify. pfold. econs; eauto.
  Qed.

  Lemma sti2raw_red_fair
        (im: imap wf) tr fm ktr
        (BEH: Beh.of_state im (Vis (Fair fm) ktr) tr)
        (NNB: tr <> Tr.nb)
        (NSPIN: tr <> Tr.spin)
    :
    exists (im0: imap wf),
      (fair_update im im0 fm) /\
        (Beh.of_state im0 (ktr tt) tr) /\
        exists evs sti,
          observe_state_trace (ktr tt, tr, im0) (evs, sti) /\
            (sti2raw (Vis (Fair fm) ktr, tr, im) =
               RawTr.app ((inl (silentE_fair fm)) :: evs) (sti2raw sti)).
  Proof.
    hexploit observe_state_fair; eauto. i. des. esplits; eauto.
    match goal with | |- ?lhs = _ => replace lhs with (RawTr.ob lhs) end.
    2:{ symmetry. apply RawTr.ob_eq. }
    ss. rewrite H2; clear H2. destruct sti as [[st0 tr0] im1].
    ss. eapply sti2raw_red_aux. eapply observe_state_trace_preserves; eauto.
  Qed.

  Lemma sti2raw_red_fair_spin
        (im: imap wf) tr fm ktr
        (BEH: Beh.of_state im (Vis (Fair fm) ktr) tr)
        (NNB: tr <> Tr.nb)
        (SPIN: tr = Tr.spin)
    :
    exists (im0: imap wf),
      (fair_update im im0 fm) /\
        (Beh.diverge_index im0 (ktr tt)) /\
        (sti2raw (Vis (Fair fm) ktr, tr, im) =
           RawTr.cons (inl (silentE_fair fm)) (sti2raw (ktr tt, tr, im0))).
  Proof.
    hexploit observe_state_fair_spin; eauto. i. des. esplits; eauto.
    match goal with | |- ?lhs = _ => replace lhs with (RawTr.ob lhs) end.
    2:{ symmetry. apply RawTr.ob_eq. }
    ss. rewrite H1; clear H1.
    ss. eapply sti2raw_red_aux2. clarify. pfold. econs; eauto.
  Qed.



  Lemma sti2raw_raw_beh_spin
        (im: imap wf) st
        (DIV: Beh.diverge_index im st)
    :
    RawBeh.of_state (R:=R) st (sti2raw (st, Tr.spin, im)).
  Proof.
    revert_until r0. pcofix CIH. i. punfold DIV. inv DIV.
    - pclearbot. hexploit sti2raw_red_tau_spin.
      4:{ i; des. rewrite H0; clear H0. pfold. econs. eauto. }
      2,3: ss. pfold. econs. pfold. econs. eauto.
    - pclearbot. hexploit sti2raw_red_choose_spin.
      4:{ i; des. rewrite H0; clear H0. pfold. econs. eauto. }
      2,3: ss. pfold. econs. pfold. econs. eauto.
    - pclearbot. hexploit sti2raw_red_fair_spin.
      4:{ i; des. rewrite H1; clear H1. pfold. econs. eauto. }
      2,3: ss. pfold. econs. pfold. econs; eauto.
    - pclearbot. hexploit sti2raw_red_ub_spin.
      3:{ i; des. rewrite H; clear H. pfold. econs. }
      all: ss.
  Qed.

  Fixpoint rawEs2tr (evs: list rawE) (tr: @Tr.t R): Tr.t :=
    match evs with
    | [] => tr
    | hd :: tl =>
        match hd with
        | inl _ => rawEs2tr tl tr
        | inr ev => Tr.cons ev (rawEs2tr tl tr)
        end
    end.

  Definition is_tau (ev: rawE): bool :=
    match ev with | inl _ => true | _ => false end.

  Lemma rawEs2tr_taus
        evs tr
        (TAUS: List.Forall is_tau evs)
    :
    rawEs2tr evs tr = tr.
  Proof.
    revert tr. induction TAUS; i; ss; clarify. destruct x; ss.
  Qed.

  Lemma rawEs2tr_done
        evs tr retv
        (DONE: rawEs2tr evs tr = Tr.done retv)
    :
    (List.Forall is_tau evs) /\ tr = Tr.done retv.
  Proof.
    induction evs; ss; clarify; eauto. des_ifs. apply IHevs in DONE. des. split; auto.
  Qed.

  Lemma rawEs2tr_spin
        evs tr
        (SPIN: rawEs2tr evs tr = Tr.spin)
    :
    (List.Forall is_tau evs) /\ tr = Tr.spin.
  Proof.
    induction evs; ss; clarify; eauto. des_ifs. apply IHevs in SPIN. des. split; auto.
  Qed.

  Lemma rawEs2tr_ub
        evs tr
        (UB: rawEs2tr evs tr = Tr.ub)
    :
    (List.Forall is_tau evs) /\ tr = Tr.ub.
  Proof.
    induction evs; ss; clarify; eauto. des_ifs. apply IHevs in UB. des. split; auto.
  Qed.

  Lemma rawEs2tr_nb
        evs tr
        (NB: rawEs2tr evs tr = Tr.nb)
    :
    (List.Forall is_tau evs) /\ tr = Tr.nb.
  Proof.
    induction evs; ss; clarify; eauto. des_ifs. apply IHevs in NB. des. split; auto.
  Qed.

  (* Lemma rawEs2tr_cons *)
  (*       evs evs0 tr obs *)
  (*       (OBS: rawEs2tr evs tr = Tr.cons obs (rawEs2tr evs0 tr)) *)
  (*   : *)
  (*   (List.Forall is_tau evs) /\ tr = Tr.nb. *)
  (* Proof. *)
  (*   induction evs; ss; clarify; eauto. des_ifs. apply IHevs in NB. des. split; auto. *)
  (* Qed. *)

  Fixpoint rawEs2st (evs: list rawE) (st: @state _ R): state :=
    match evs with
    | [] => st
    | hd :: tl =>
        match hd with
        | inl silentE_tau => Tau (rawEs2st tl st)
        | inl (silentE_fair fm) => Vis (Fair fm) (fun _ => (rawEs2st tl st))
        | inr (obsE_syscall fn args rv) => st
        end
    end.

  (* Lemma rawEs2tr_done *)
  (*       evs tr retv *)
  (*       (DONE: rawEs2tr evs tr = Tr.done retv) *)
  (*   : *)
  (*   (List.Forall is_tau evs) /\ tr = Tr.done retv. *)
  (* Proof. *)
  (*   induction evs; ss; clarify; eauto. des_ifs. apply IHevs in DONE. des. split; auto. *)
  (* Qed. *)

  (* Lemma rawEs2tr_spin *)
  (*       evs tr *)
  (*       (SPIN: rawEs2tr evs tr = Tr.spin) *)
  (*   : *)
  (*   (List.Forall is_tau evs) /\ tr = Tr.spin. *)
  (* Proof. *)
  (*   induction evs; ss; clarify; eauto. des_ifs. apply IHevs in SPIN. des. split; auto. *)
  (* Qed. *)

  (* Lemma rawEs2tr_ub *)
  (*       evs tr *)
  (*       (UB: rawEs2tr evs tr = Tr.ub) *)
  (*   : *)
  (*   (List.Forall is_tau evs) /\ tr = Tr.ub. *)
  (* Proof. *)
  (*   induction evs; ss; clarify; eauto. des_ifs. apply IHevs in UB. des. split; auto. *)
  (* Qed. *)

  (* Lemma rawEs2tr_nb *)
  (*       evs tr *)
  (*       (NB: rawEs2tr evs tr = Tr.nb) *)
  (*   : *)
  (*   (List.Forall is_tau evs) /\ tr = Tr.nb. *)
  (* Proof. *)
  (*   induction evs; ss; clarify; eauto. des_ifs. apply IHevs in NB. des. split; auto. *)
  (* Qed. *)

  (* Lemma rawEs2tr_cons *)
  (*       evs evs0 tr obs *)
  (*       (OBS: rawEs2tr evs tr = Tr.cons obs (rawEs2tr evs0 tr)) *)
  (*   : *)
  (*   (List.Forall is_tau evs) /\ tr = Tr.nb. *)
  (* Proof. *)
  (*   induction evs; ss; clarify; eauto. des_ifs. apply IHevs in NB. des. split; auto. *)
  (* Qed. *)

  (* Lemma rawEs2st_taus *)
  (*       evs st raw *)
  (*       (BEH: RawBeh.of_state st raw) *)
  (*       (TAUS: List.Forall is_tau evs) *)
  (*   : *)
    

  (* Heqetr : List.Forall (fun ev : rawE => is_tau ev) evs *)
  (* WF : wf_evs evs *)
  (* ============================ *)
  (* paco3 RawBeh._of_state r R (rawEs2st evs (Ret retv)) (RawTr.app evs (RawTr.done retv)) *)

  Lemma beh_rawEs
        evs (im: imap wf) st tr
        (BEH: Beh.of_state im st (rawEs2tr evs tr))
        (WF: wf_evs evs)
    :
    Beh.of_state (R:=R) im (rawEs2st evs st) (rawEs2tr evs tr).
  Proof.
    ginit. revert_until r0. gcofix CIH; i. move WF before CIH. revert_until WF.
    induction WF; i; ss; clarify.
    { gfinal. right. eapply paco4_mon; eauto. ss. }
    { des_ifs.
      { guclo Beh.of_state_indC_spec. econs. eauto. }
      { guclo Beh.of_state_indC_spec. econs. all: admit. }
    }
    { des_ifs. gfinal. right. eapply paco4_mon. eauto. ss. }
  Abort.

  Lemma _sti2raw_raw_beh
        evs (im0 im1: imap wf) st0 st1 tr0 tr1
        (* evs (im: imap wf) st tr *)
        (* (BEH: Beh.of_state im st (rawEs2tr evs tr)) *)
        (BEH: Beh.of_state im0 st0 tr0)
        (OST: observe_state_trace (st0, tr0, im0) (evs, (st1, tr1, im1)))
        (* (WF: wf_evs evs) *)
    :
    RawBeh.of_state (R:=R) st0 (_sti2raw evs (st1, tr1, im1)).
    (* RawBeh.of_state (R:=R) (rawEs2st evs st) (_sti2raw evs (st, tr, im)). *)
  Proof.
    revert_until r0. pcofix CIH. i.
    remember (st0, tr0, im0) as sti0. remember (ev :: evs) as eevs.
    remember (st1, tr1, im1) as sti1. remember (eevs, sti1) as eesti1.
    move OST before r0. revert_until OST. induction OST; i; ss; clarify.
    { rewrite _sti2raw_red_evs. ss. pfold. econs. right.
      hexploit (CIH []). eauto.
      2:{ i. rewrite _sti2raw_red_evs in H. ss.

          left.
          remember (ktr rv) as st. clear Heqst ktr rv fn args.
          rename im0 into im, tr1 into tr.
          induction BEH using @Beh.of_state_ind2; ss; clarify; eauto.
          4:{ rewrite sti2raw_red_obs; eauto. pfold. econs. right.
              eapply (CIH []) in BEH. rewrite _sti2raw_red_evs in BEH. ss. eauto.
              

    destruct evs as [| ev evs].
    { rewrite _sti2raw_red_evs. ss. inv OST.
      { rewrite sti2raw_red_ret. pfold. econs. }
      { destruct (classic (tr1 = Tr.nb)) as [NB | NNB]; clarify.
        { rewrite sti2raw_red_nb. pfold. econs. }
        destruct (classic (tr1 = Tr.spin)) as [SPIN | NSPIN]; clarify.
        { rewrite sti2raw_red_ub_spin; ss. pfold. eauto. }
        rewrite sti2raw_red_ub; ss. pfold. eauto. }
      { rewrite sti2raw_red_nb. pfold. econs. }
    }




    revert_until r0. pcofix CIH. i.
    remember (st0, tr0, im0) as sti0. remember (ev :: evs) as eevs.
    remember (st1, tr1, im1) as sti1. remember (eevs, sti1) as eesti1.
    move OST before r0. revert_until OST. induction OST; i; ss; clarify.
    { rewrite _sti2raw_red_evs. ss. pfold. econs. right.
      hexploit (CIH []). eauto.
      2:{ i. rewrite _sti2raw_red_evs in H. ss.

          left.
          remember (ktr rv) as st. clear Heqst ktr rv fn args.
          rename im0 into im, tr1 into tr.
          induction BEH using @Beh.of_state_ind2; ss; clarify; eauto.
          4:{ rewrite sti2raw_red_obs; eauto. pfold. econs. right.
              eapply (CIH []) in BEH. rewrite _sti2raw_red_evs in BEH. ss. eauto.
              



    revert_until r0. pcofix CIH. i.
    remember (st0, tr0, im0) as sti0. remember (evs, (st1, tr1, im1)) as esti1.
    move OST before r0. revert_until OST. induction OST; i; ss; clarify.
    2:{ rewrite _sti2raw_red_evs. ss. pfold. econs. right.
        hexploit (CIH []). eauto.
        2:{ i. rewrite _sti2raw_red_evs in H. ss.

        left.
        remember (ktr rv) as st. clear Heqst ktr rv fn args.
        rename im0 into im, tr1 into tr.
        induction BEH using @Beh.of_state_ind2; ss; clarify; eauto.
        4:{ rewrite sti2raw_red_obs; eauto. pfold. econs. right.
            eapply (CIH []) in BEH. rewrite _sti2raw_red_evs in BEH. ss. eauto.
            




    move WF before CIH. revert_until WF.
    induction WF; i; ss.
    { rewrite _sti2raw_red_evs. ss. induction BEH using @Beh.of_state_ind2.
      { hexploit sti2raw_red_ret. i. rewrite H; clear H. pfold. econs. }
      4:{ hexploit sti2raw_red_tau.
          4:{ i; des. rewrite H1; clear H1. ss. pfold. econs. admit. }
          all: admit. }
      all: admit.
    }
    { des_ifs.
      { rewrite _sti2raw_red_evs. ss. pfold. econs.
        rewrite <- _sti2raw_red_evs. eauto. }
      { rewrite _sti2raw_red_evs. ss. pfold. econs.
        rewrite <- _sti2raw_red_evs. eauto. }
    }
    { des_ifs. rewrite _sti2raw_red_evs. ss.
      match goal with | BEH: Beh.of_state _ _ ?_tr |- _ => remember _tr as otr end.
      move BEH before CIH. revert_until BEH.
      induction BEH using @Beh.of_state_ind2; i; ss; clarify.
      { pfold. econs.

        pclearbot. right.
        hexploit (CIH []). ss. eapply TL. ss. i; ss. rewrite _sti2raw_red_evs in H. ss.
        eapply CIH in TL.
      { 


    
    remember (rawEs2tr evs tr) as etr. remember (rawEs2st evs st) as est.
    move BEH before CIH. revert_until BEH.
    induction BEH using @Beh.of_state_ind2; i; clarify.
    5:{ rewrite _sti2raw_red_evs. hexploit sti2raw_red_tau.
        4:{ i; des. rewrite H1; clear H1. ss.
    { symmetry in Heqetr; eapply rawEs2tr_done in Heqetr. des. clarify.
      rewrite _sti2raw_red_evs. rewrite sti2raw_red_ret.
      (*TODO*)
      pfold. econs. }
    { eapply paco3_mon. eapply sti2raw_raw_beh_spin; eauto. ss. }
    { rewrite sti2raw_red_nb. pfold. econs. }
    { rewrite sti2raw_red_obs; eauto. pfold. econs; eauto. }
    { destruct (classic (tr = Tr.nb)) as [NB | NNB]; clarify.
      { rewrite sti2raw_red_nb. pfold. econs. }
      destruct (classic (tr = Tr.spin)) as [SPIN | NSPIN]; clarify.
      { hexploit sti2raw_red_tau_spin.
        4:{ i; des. rewrite H0; clear H0. pfold. econs; eauto. }
        2,3: ss. eapply Beh.beh_tau0; eauto. }
      { hexploit sti2raw_red_tau.
        4:{ i; des. rewrite H1; clear H1. ss. pfold. econs; eauto. }



        (*TODO*)
      rewrite sti2raw_red_tau; eauto. pfold. econs; eauto. }
    { pose (classic (tr0 = Tr.nb)) as NB. des; clarify.
      { rewrite sti2raw_red_nb. pfold. econs. }
      hexploit sti2raw_red_choose; eauto.
      2:{ i; des. setoid_rewrite H0; clear H0. pfold. econs; eauto. }
      pfold. econs. punfold WF. }
    { pose (classic (tr0 = Tr.nb)) as NB. des; clarify.
      { rewrite sti2raw_red_nb. pfold. econs. }
      rewrite sti2raw_red_fair; eauto. pfold. econs; eauto. }
    { pfold. econs. }
  Qed.

  Lemma _sti2raw_raw_beh
        evs (im: imap wf) st tr
        (BEH: Beh.of_state im st (rawEs2tr evs tr))
        (WF: wf_evs evs)
    :
    RawBeh.of_state (R:=R) (rawEs2st evs st) (_sti2raw evs (st, tr, im)).
  Proof.
    revert_until r0. pcofix CIH. i. remember (rawEs2tr evs tr) as etr.
    move BEH before CIH. revert_until BEH.
    induction BEH using @Beh.of_state_ind2; i; clarify.
    5:{ rewrite _sti2raw_red_evs. hexploit sti2raw_red_tau.
        4:{ i; des. rewrite H1; clear H1. ss.
    { symmetry in Heqetr; eapply rawEs2tr_done in Heqetr. des. clarify.
      rewrite _sti2raw_red_evs. rewrite sti2raw_red_ret.
      (*TODO*)
      pfold. econs. }
    { eapply paco3_mon. eapply sti2raw_raw_beh_spin; eauto. ss. }
    { rewrite sti2raw_red_nb. pfold. econs. }
    { rewrite sti2raw_red_obs; eauto. pfold. econs; eauto. }
    { destruct (classic (tr = Tr.nb)) as [NB | NNB]; clarify.
      { rewrite sti2raw_red_nb. pfold. econs. }
      destruct (classic (tr = Tr.spin)) as [SPIN | NSPIN]; clarify.
      { hexploit sti2raw_red_tau_spin.
        4:{ i; des. rewrite H0; clear H0. pfold. econs; eauto. }
        2,3: ss. eapply Beh.beh_tau0; eauto. }
      { hexploit sti2raw_red_tau.
        4:{ i; des. rewrite H1; clear H1. ss. pfold. econs; eauto. }



        (*TODO*)
      rewrite sti2raw_red_tau; eauto. pfold. econs; eauto. }
    { pose (classic (tr0 = Tr.nb)) as NB. des; clarify.
      { rewrite sti2raw_red_nb. pfold. econs. }
      hexploit sti2raw_red_choose; eauto.
      2:{ i; des. setoid_rewrite H0; clear H0. pfold. econs; eauto. }
      pfold. econs. punfold WF. }
    { pose (classic (tr0 = Tr.nb)) as NB. des; clarify.
      { rewrite sti2raw_red_nb. pfold. econs. }
      rewrite sti2raw_red_fair; eauto. pfold. econs; eauto. }
    { pfold. econs. }
  Qed.


  Theorem sti2raw_raw_beh
          (im: imap wf) st tr
          (BEH: Beh.of_state im st tr)
    :
    RawBeh.of_state (R:=R) st (sti2raw (st, tr, im)).
  Proof.
    revert_until r0. pcofix CIH. i. induction BEH using @Beh.of_state_ind2; clarify.
    { rewrite sti2raw_red_ret. pfold. econs. }
    { eapply paco3_mon. eapply sti2raw_raw_beh_spin; eauto. ss. }
    { rewrite sti2raw_red_nb. pfold. econs. }
    { rewrite sti2raw_red_obs; eauto. pfold. econs; eauto. }
    { destruct (classic (tr = Tr.nb)) as [NB | NNB]; clarify.
      { rewrite sti2raw_red_nb. pfold. econs. }
      destruct (classic (tr = Tr.spin)) as [SPIN | NSPIN]; clarify.
      { hexploit sti2raw_red_tau_spin.
        4:{ i; des. rewrite H0; clear H0. pfold. econs; eauto. }
        2,3: ss. eapply Beh.beh_tau0; eauto. }
      { hexploit sti2raw_red_tau.
        4:{ i; des. rewrite H1; clear H1. ss. pfold. econs; eauto. }



        (*TODO*)
      rewrite sti2raw_red_tau; eauto. pfold. econs; eauto. }
    { pose (classic (tr0 = Tr.nb)) as NB. des; clarify.
      { rewrite sti2raw_red_nb. pfold. econs. }
      hexploit sti2raw_red_choose; eauto.
      2:{ i; des. setoid_rewrite H0; clear H0. pfold. econs; eauto. }
      pfold. econs. punfold WF. }
    { pose (classic (tr0 = Tr.nb)) as NB. des; clarify.
      { rewrite sti2raw_red_nb. pfold. econs. }
      rewrite sti2raw_red_fair; eauto. pfold. econs; eauto. }
    { pfold. econs. }
  Qed.



  Lemma raw_spin_trace_ob
        R
    :
    raw_spin_trace = (@RawTr.ob _ R raw_spin_trace).
  Proof.
    apply RawTr.ob_eq.
  Qed.

  Lemma raw_spin_trace_spec
        R
    :
    @raw_spin _ R raw_spin_trace.
  Proof.
    pcofix CIH. rewrite raw_spin_trace_ob. pfold. econs. right. eapply CIH.
  Qed.

  Lemma sti2raw_raw_spin
        R itr
        (WFS: @wf_spin R itr)
    :
    raw_spin (sti2raw (itr, Tr.spin)).
  Proof.
    revert_until R. pcofix CIH; i. punfold WFS. inv WFS.
    - pclearbot. rewrite sti2raw_red_tau; ss; eauto. pfold. econs. eauto.
    - pclearbot. hexploit sti2raw_red_choose.
      3:{ i. des. setoid_rewrite H0; clear H0. pfold. econs. right. eapply CIH. eapply wf_tr_spin_wf_spin; eauto. }
      2: ss. pfold. econs. pfold. econs. eauto.
    - pclearbot. rewrite sti2raw_red_fair; ss; eauto. pfold. econs. eauto.
    - rewrite sti2raw_red_ub_spin; ss; eauto. pose raw_spin_trace_spec.
      eapply paco2_mon. eapply r0. ss.
  Qed.

  Lemma sti2raw_extract_spin
        R st
        (WFS: @wf_spin R st)
    :
    extract_tr (sti2raw (st, Tr.spin)) Tr.spin.
  Proof.
    ginit. revert_until R. gcofix CIH. i.
    punfold WFS. inv WFS.
    - pclearbot. rewrite sti2raw_red_tau; ss; eauto. gfinal. right. pfold. econs.
      pfold. econs. left. eapply sti2raw_raw_spin; eauto.
    - pclearbot. hexploit sti2raw_red_choose.
      3:{ i. des. setoid_rewrite H0; clear H0. gfinal. right. pfold. econs.
          pfold. econs. left. eapply wf_tr_spin_wf_spin in H. eapply sti2raw_raw_spin; eauto. }
      2: ss. pfold. econs. pfold. econs. eauto.
    - pclearbot. rewrite sti2raw_red_fair; ss; eauto. gfinal. right. pfold. econs.
      pfold. econs. left. eapply sti2raw_raw_spin; eauto.
    - rewrite sti2raw_red_ub_spin; ss. gfinal. right. pfold. econs. eapply raw_spin_trace_spec.
  Qed.

  Theorem sti2raw_extract
          R (sttr: @st_tr_im R)
          (WF: wf_tr sttr)
    :
    extract_tr (sti2raw sttr) (snd sttr).
  Proof.
    ginit. revert_until R. gcofix CIH. i.
    pose proof WF as WF0. revert WF0.
    induction WF using wf_tr_ind2; i; clarify.
    { rewrite sti2raw_red_ret. gfinal. right. pfold. econs. }
    { rewrite sti2raw_red_obs; eauto. gfinal; right. pfold. econs; eauto. eapply CIH in WF. ss. right; eauto. }
    { gfinal; right. eapply sti2raw_extract_spin in H. ss. eapply paco3_mon; eauto. ss. }
    { pose (classic (tr = Tr.nb)) as NB. des; clarify.
      { rewrite sti2raw_red_nb. gfinal; right. pfold. econs. }
      rewrite sti2raw_red_tau; eauto. guclo extract_tr_indC_spec. econs. eauto.
    }
    { pose (classic (tr = Tr.nb)) as NB. des; clarify.
      { rewrite sti2raw_red_nb. gfinal; right. pfold. econs. }
      hexploit sti2raw_red_choose.
      3:{ i; des. setoid_rewrite H0; clear H0. ss. guclo extract_tr_indC_spec. econs.
          (*TODO*)
          gfinal. right. 


          gfinal. right. pfold. econs.


          guclo extract_tr_indC_spec. econs.

          pfold. econs; eauto. right. eapply CIH.

      
      { pfold. econs. left. eapply WF0. }
      admit.
    }
    { pclearbot. pose (classic (tr = Tr.nb)) as NB. des; clarify.
      { rewrite sti2raw_red_nb. pfold. econs. }
      rewrite sti2raw_red_fair; eauto. pfold. econs; eauto. }
    { pfold. econs. }
    { pfold. rewrite sti2raw_red_nb. econs. }



  Admitted.

End ExtractRaw.



Section FAIR.

  Context {Ident: ID}.
  Variable wf: WF.

  Theorem extract_preserves_fairness
          R (st: @state _ R) (im: imap wf) tr raw
          (BEH: Beh.of_state im st tr)
          (* (EXT: extract_tr raw tr) *)
    :
    RawTr.is_fair_ord wf (sti2raw (st, tr)).
  Proof.
  Admitted.

  Theorem rawbeh_extract_is_beh
          R (st: state (R:=R)) (raw: RawTr.t (R:=R)) tr
          (BEH: RawBeh.of_state_fair_ord (wf:=wf) st raw)
          (EXT: extract_tr raw tr)
    :
    exists (im: imap wf), Beh.of_state im st tr.
  Admitted.

End FAIR.



Section EQUIV.

  Context {Ident: ID}.
  Variable wf: WF.

  Theorem IndexBeh_implies_SelectBeh
          R (st: state (R:=R)) (tr: Tr.t (R:=R)) (im: imap wf)
          (BEH: Beh.of_state im st tr)
    :
    exists raw, (<<EXTRACT: extract_tr raw tr>>) /\ (<<BEH: RawBeh.of_state_fair_ord (wf:=wf) st raw>>).
  Proof.
  Admitted.

  Theorem SelectBeh_implies_IndexBeh
          R (st: state (R:=R)) (raw: RawTr.t (R:=R))
          (BEH: RawBeh.of_state_fair_ord (wf:=wf) st raw)
    :
    exists (im: imap wf) tr, (<<EXTRACT: extract_tr raw tr>>) /\ (<<BEH: Beh.of_state im st tr>>).
  Proof.
  Admitted.

End EQUIV.
