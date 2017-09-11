(* ========================================================================= *)
(* Simple formulation of group theory with a type of "(A)group".             *)
(* ========================================================================= *)

let group_tybij =
  let eth = prove
   (`?s (z:A) n a.
          z IN s /\
          (!x. x IN s ==> n x IN s) /\
          (!x y. x IN s /\ y IN s ==> a x y IN s) /\
          (!x y z. x IN s /\ y IN s /\ z IN s
                   ==> a x (a y z) = a (a x y) z) /\
          (!x. x IN s ==> a z x = x /\ a x z = x) /\
          (!x. x IN s ==> a (n x) x = z /\ a x (n x) = z)`,
    MAP_EVERY EXISTS_TAC
     [`{ARB:A}`; `ARB:A`; `(\x. ARB):A->A`; `(\x y. ARB):A->A->A`] THEN
    REWRITE_TAC[IN_SING] THEN MESON_TAC[]) in
  new_type_definition "group" ("group","group_operations")
   (GEN_REWRITE_RULE DEPTH_CONV [EXISTS_UNPAIR_THM] eth);;

let group_carrier = new_definition
 `(group_carrier:(A)group->A->bool) = \g. FST(group_operations g)`;;

let group_id = new_definition
 `(group_id:(A)group->A) = \g. FST(SND(group_operations g))`;;

let group_inv = new_definition
 `(group_inv:(A)group->A->A) = \g. FST(SND(SND(group_operations g)))`;;

let group_op = new_definition
 `(group_op:(A)group->A->A->A) = \g. SND(SND(SND(group_operations g)))`;;

let ([GROUP_ID; GROUP_INV; GROUP_OP; GROUP_OP_ASSOC;
      GROUP_OP_LID; GROUP_OP_RID; GROUP_OP_LINV; GROUP_OP_RINV] as
     GROUP_PROPERTIES) = (CONJUNCTS o prove)
 (`(!G:A group. group_id G IN group_carrier G) /\
   (!G x:A. x IN group_carrier G ==> group_inv G x IN group_carrier G) /\
   (!G x y:A. x IN group_carrier G /\ y IN group_carrier G
              ==> group_op G x y IN group_carrier G) /\
   (!G x y z:A. x IN group_carrier G /\
                y IN group_carrier G /\
                z IN group_carrier G
                ==> group_op G x (group_op G y z) =
                    group_op G (group_op G x y) z) /\
   (!G x:A. x IN group_carrier G ==> group_op G (group_id G) x = x) /\
   (!G x:A. x IN group_carrier G ==> group_op G x (group_id G) = x) /\
   (!G x:A. x IN group_carrier G
            ==> group_op G (group_inv G x) x = group_id G) /\
   (!G x:A. x IN group_carrier G
            ==> group_op G x(group_inv G x) = group_id G)`,
  REWRITE_TAC[AND_FORALL_THM] THEN GEN_TAC THEN
  MP_TAC(SPEC `G:A group` (MATCH_MP(MESON[]
   `(!a. mk(dest a) = a) /\ (!r. P r <=> dest(mk r) = r)
    ==> !a. P(dest a)`) group_tybij)) THEN
  REWRITE_TAC[group_carrier; group_id; group_inv; group_op] THEN
  SIMP_TAC[]);;

let GROUPS_EQ = prove
 (`!G H:A group.
        G = H <=>
        group_carrier G = group_carrier H /\
        group_id G = group_id H /\
        group_inv G = group_inv H /\
        group_op G = group_op H`,
  REWRITE_TAC[MESON[group_tybij]
   `g = h <=> group_operations g = group_operations h`] THEN
  REWRITE_TAC[group_carrier;group_id;group_inv;group_op] THEN
  REWRITE_TAC[GSYM PAIR_EQ]);;

let GROUP_CARRIER_NONEMPTY = prove
 (`!G:A group. ~(group_carrier G = {})`,
  MESON_TAC[MEMBER_NOT_EMPTY; GROUP_ID]);;

(* ------------------------------------------------------------------------- *)
(* The trivial group on a given object.                                      *)
(* ------------------------------------------------------------------------- *)

let singleton_group = new_definition
 `singleton_group (a:A) = group({a},a,(\x. a),(\x y. a))`;;

let SINGLETON_GROUP = prove
 (`(!a:A. group_carrier(singleton_group a) = {a}) /\
   (!a:A. group_id(singleton_group a) = a) /\
   (!a:A. group_inv(singleton_group a) = \x. a) /\
   (!a:A. group_op(singleton_group a) = \x y. a)`,
  REWRITE_TAC[AND_FORALL_THM] THEN GEN_TAC THEN
  MP_TAC(fst(EQ_IMP_RULE
   (ISPEC(rand(rand(snd(strip_forall(concl singleton_group)))))
   (CONJUNCT2 group_tybij)))) THEN
  REWRITE_TAC[GSYM singleton_group] THEN SIMP_TAC[IN_SING] THEN
  SIMP_TAC[group_carrier; group_id; group_inv; group_op]);;

let trivial_group = new_definition
 `trivial_group G <=> group_carrier G = {group_id G}`;;

let TRIVIAL_GROUP_SINGLETON_GROUP = prove
 (`!a:A. trivial_group(singleton_group a)`,
  REWRITE_TAC[trivial_group; SINGLETON_GROUP]);;

let TRIVIAL_GROUP = prove
 (`!G:A group. trivial_group G <=> ?a. group_carrier G = {a}`,
  GEN_TAC THEN REWRITE_TAC[trivial_group] THEN MATCH_MP_TAC(SET_RULE
   `c IN s ==> (s = {c} <=> ?a. s = {a})`) THEN
  REWRITE_TAC[GROUP_ID]);;

let TRIVIAL_GROUP_ALT = prove
 (`!G:A group. trivial_group G <=> ?a. group_carrier G SUBSET {a}`,
  REWRITE_TAC[TRIVIAL_GROUP; GROUP_CARRIER_NONEMPTY; SET_RULE
   `(?a. s = {a}) <=> (?a. s SUBSET {a}) /\ ~(s = {})`]);;

(* ------------------------------------------------------------------------- *)
(* Opposite group (mainly just to avoid some duplicated variant proofs).     *)
(* ------------------------------------------------------------------------- *)

let opposite_group = new_definition
 `opposite_group(G:A group) =
        group(group_carrier G,group_id G,group_inv G,
              \x y. group_op G y x)`;;

let OPPOSITE_GROUP = prove
 (`!G:A group.
        group_carrier(opposite_group G) = group_carrier G /\
        group_id(opposite_group G) = group_id G /\
        group_inv(opposite_group G) = group_inv G /\
        group_op(opposite_group G) = \x y. group_op G y x`,
  GEN_TAC THEN
  MP_TAC(fst(EQ_IMP_RULE
   (ISPEC(rand(rand(snd(strip_forall(concl opposite_group)))))
   (CONJUNCT2 group_tybij)))) THEN
  REWRITE_TAC[GSYM opposite_group] THEN ANTS_TAC THENL
   [SIMP_TAC GROUP_PROPERTIES;
    SIMP_TAC[group_carrier; group_id; group_inv; group_op]]);;

let OPPOSITE_OPPOSITE_GROUP = prove
 (`!G:A group. opposite_group (opposite_group G) = G`,
  GEN_TAC THEN ONCE_REWRITE_TAC[opposite_group] THEN
  REWRITE_TAC[OPPOSITE_GROUP; ETA_AX] THEN
  GEN_REWRITE_TAC RAND_CONV [GSYM(CONJUNCT1 group_tybij)] THEN
  AP_TERM_TAC THEN REWRITE_TAC[group_carrier; group_id; group_inv; group_op]);;

let OPPOSITE_GROUP_INV = prove
 (`!G x:A. group_inv(opposite_group G) x = group_inv G x`,
  REWRITE_TAC[OPPOSITE_GROUP]);;

let OPPOSITE_GROUP_OP = prove
 (`!G x y:A. group_op(opposite_group G) x y = group_op G y x`,
  REWRITE_TAC[OPPOSITE_GROUP]);;

(* ------------------------------------------------------------------------- *)
(* Derived operations and derived properties.                                *)
(* ------------------------------------------------------------------------- *)

let group_div = new_definition
 `group_div G x y = group_op G x (group_inv G y)`;;

let GROUP_DIV = prove
 (`!G x y:A.
        x IN group_carrier G /\ y IN group_carrier G
        ==> (group_div G x y) IN group_carrier G`,
  SIMP_TAC[group_div; GROUP_OP; GROUP_INV]);;

let GROUP_OP_LCANCEL = prove
 (`!G x y z:A.
        x IN group_carrier G /\ y IN group_carrier G /\ z IN group_carrier G
        ==> (group_op G x y = group_op G x z <=> y = z)`,
  REPEAT STRIP_TAC THEN EQ_TAC THEN DISCH_TAC THEN ASM_REWRITE_TAC[] THEN
  FIRST_X_ASSUM(MP_TAC o AP_TERM `group_op G (group_inv G x):A->A`) THEN
  ASM_SIMP_TAC[GROUP_OP_ASSOC; GROUP_INV; GROUP_OP_LINV; GROUP_OP_LID]);;

let GROUP_OP_RCANCEL = prove
 (`!G x y z:A.
        x IN group_carrier G /\ y IN group_carrier G /\ z IN group_carrier G
        ==> (group_op G x z = group_op G y z <=> x = y)`,
  ONCE_REWRITE_TAC[GSYM OPPOSITE_GROUP_OP] THEN
  SIMP_TAC[GROUP_OP_LCANCEL; OPPOSITE_GROUP]);;

let GROUP_LID_UNIQUE = prove
 (`!G x y:A.
        x IN group_carrier G /\ y IN group_carrier G /\ group_op G x y = y
        ==> x = group_id G`,
  MESON_TAC[GROUP_OP_RCANCEL; GROUP_OP_LID; GROUP_OP; GROUP_ID]);;

let GROUP_RID_UNIQUE = prove
 (`!G x y:A.
        x IN group_carrier G /\ y IN group_carrier G /\ group_op G x y = x
        ==> y = group_id G`,
  MESON_TAC[GROUP_OP_LCANCEL; GROUP_OP_RID; GROUP_OP; GROUP_ID]);;

let GROUP_LID_EQ = prove
 (`!G x y:A.
        x IN group_carrier G /\ y IN group_carrier G
        ==> (group_op G x y = y <=> x = group_id G)`,
  MESON_TAC[GROUP_LID_UNIQUE; GROUP_OP_LID]);;

let GROUP_RID_EQ = prove
 (`!G x y:A.
        x IN group_carrier G /\ y IN group_carrier G
        ==> (group_op G x y = x <=> y = group_id G)`,
  MESON_TAC[GROUP_RID_UNIQUE; GROUP_OP_RID]);;

let GROUP_LINV_UNIQUE = prove
 (`!G x y:A.
        x IN group_carrier G /\ y IN group_carrier G /\
        group_op G x y = group_id G
        ==> group_inv G x = y`,
  MESON_TAC[GROUP_OP_LCANCEL; GROUP_INV; GROUP_OP_RINV]);;

let GROUP_RINV_UNIQUE = prove
 (`!G x y:A.
        x IN group_carrier G /\ y IN group_carrier G /\
        group_op G x y = group_id G
        ==> group_inv G y = x`,
  MESON_TAC[GROUP_OP_RCANCEL; GROUP_INV; GROUP_OP_LINV]);;

let GROUP_LINV_EQ = prove
 (`!G x y:A.
        x IN group_carrier G /\ y IN group_carrier G
        ==> (group_inv G x = y <=> group_op G x y = group_id G)`,
  MESON_TAC[GROUP_LINV_UNIQUE; GROUP_OP_RINV]);;

let GROUP_RINV_EQ = prove
 (`!G x y:A.
        x IN group_carrier G /\ y IN group_carrier G
        ==> (group_inv G x = y <=> group_op G y x = group_id G)`,
  MESON_TAC[GROUP_RINV_UNIQUE; GROUP_OP_LINV]);;

let GROUP_INV_INV = prove
 (`!G x:A. x IN group_carrier G ==> group_inv G (group_inv G x) = x`,
  REPEAT STRIP_TAC THEN MATCH_MP_TAC GROUP_LINV_UNIQUE THEN
  ASM_SIMP_TAC[GROUP_INV; GROUP_OP_LINV]);;

let GROUP_INV_ID = prove
 (`!G:A group. group_inv G (group_id G) = group_id G`,
  GEN_TAC THEN MATCH_MP_TAC GROUP_LINV_UNIQUE THEN
  SIMP_TAC[GROUP_ID; GROUP_OP_LID]);;

let GROUP_INV_EQ_ID = prove
 (`!G x:A.
        x IN group_carrier G
        ==> (group_inv G x = group_id G <=> x = group_id G)`,
  MESON_TAC[GROUP_INV_INV; GROUP_INV_ID]);;

let GROUP_INV_OP = prove
 (`!G x y:A.
        x IN group_carrier G /\ y IN group_carrier G
        ==> group_inv G (group_op G x y) =
            group_op G (group_inv G y) (group_inv G x)`,
  REPEAT STRIP_TAC THEN MATCH_MP_TAC GROUP_LINV_UNIQUE THEN
  ASM_SIMP_TAC[GROUP_OP; GROUP_INV; GROUP_OP_ASSOC] THEN
  W(MP_TAC o PART_MATCH (rand o rand)
    GROUP_OP_ASSOC o lhand o lhand o snd) THEN
  ASM_SIMP_TAC[GROUP_OP_RINV; GROUP_INV] THEN
  DISCH_THEN(SUBST1_TAC o SYM) THEN
  ASM_SIMP_TAC[GROUP_OP_RINV; GROUP_INV; GROUP_OP_RID]);;

let GROUP_DIV_REFL = prove
 (`!G x:A. x IN group_carrier G ==> group_div G x x = group_id G`,
  SIMP_TAC[group_div; GROUP_OP_RINV]);;

let GROUP_DIV_EQ_ID = prove
 (`!G x y:A.
        x IN group_carrier G /\ y IN group_carrier G
        ==> (group_div G x y = group_id G <=> x = y)`,
  REPEAT STRIP_TAC THEN
  SUBGOAL_THEN `group_id G:A = group_div G y y` SUBST1_TAC THENL
   [ASM_SIMP_TAC[GROUP_DIV_REFL];
    ASM_SIMP_TAC[group_div; GROUP_OP_RCANCEL; GROUP_INV]]);;

(* ------------------------------------------------------------------------- *)
(* Subgroups. We treat them as *sets* which seems to be a common convention. *)
(* And "subgroup_generated" can be used in the degenerate case where the set *)
(* is closed under the operations to cast from "subset" to "group".          *)
(* ------------------------------------------------------------------------- *)

parse_as_infix ("subgroup_of",(12,"right"));;

let subgroup_of = new_definition
  `(s:A->bool) subgroup_of (G:A group) <=>
        s SUBSET group_carrier G /\
        group_id G IN s /\
        (!x. x IN s ==> group_inv G x IN s) /\
        (!x y. x IN s /\ y IN s ==> group_op G x y IN s)`;;

let SUBGROUP_OF_INTERS = prove
 (`!G (gs:(A->bool)->bool).
        (!g. g IN gs ==> g subgroup_of G) /\ ~(gs = {})
        ==> (INTERS gs) subgroup_of G`,
  REWRITE_TAC[subgroup_of; SUBSET; IN_INTERS] THEN SET_TAC[]);;

let SUBGROUP_OF_INTER = prove
 (`!G g h:A->bool.
        g subgroup_of G /\ h subgroup_of G ==> (g INTER h) subgroup_of G`,
  REWRITE_TAC[subgroup_of; SUBSET; IN_INTER] THEN SET_TAC[]);;

let SUBGROUP_OF_OPPOSITE_GROUP = prove
 (`!G h:A->bool. h subgroup_of opposite_group G <=> h subgroup_of G`,
  REWRITE_TAC[subgroup_of; OPPOSITE_GROUP] THEN MESON_TAC[]);;

let SUBGROUP_OF_IMP_SUBSET = prove
 (`!G s:A->bool. s subgroup_of G ==> s SUBSET group_carrier G`,
  SIMP_TAC[subgroup_of]);;

let SUBGROUP_OF_IMP_NONEMPTY = prove
 (`!G s:A->bool. s subgroup_of G ==> ~(s = {})`,
  REWRITE_TAC[subgroup_of] THEN SET_TAC[]);;

let TRIVIAL_SUBGROUP_OF = prove
 (`!G:A group. {group_id G} subgroup_of G`,
  SIMP_TAC[subgroup_of; IN_SING; SING_SUBSET] THEN
  MESON_TAC GROUP_PROPERTIES);;

let CARRIER_SUBGROUP_OF = prove
 (`!G:A group. (group_carrier G) subgroup_of G`,
  REWRITE_TAC[subgroup_of; SUBSET_REFL] THEN MESON_TAC GROUP_PROPERTIES);;

let subgroup_generated = new_definition
 `subgroup_generated G (s:A->bool) =
      group(INTERS {h | h subgroup_of G /\ (group_carrier G INTER s) SUBSET h},
            group_id G,group_inv G,group_op G)`;;

let SUBGROUP_GENERATED = prove
 (`(!G s:A->bool.
        group_carrier (subgroup_generated G s) =
          INTERS {h | h subgroup_of G /\ (group_carrier G INTER s) SUBSET h}) /\
    (!G s:A->bool. group_id (subgroup_generated G s) = group_id G) /\
    (!G s:A->bool. group_inv (subgroup_generated G s) = group_inv G) /\
    (!G s:A->bool. group_op (subgroup_generated G s) = group_op G)`,
  REWRITE_TAC[AND_FORALL_THM] THEN REPEAT GEN_TAC THEN
  MP_TAC(fst(EQ_IMP_RULE
   (ISPEC(rand(rand(snd(strip_forall(concl subgroup_generated)))))
   (CONJUNCT2 group_tybij)))) THEN
  REWRITE_TAC[GSYM subgroup_generated] THEN ANTS_TAC THENL
   [REWRITE_TAC[INTERS_GSPEC; IN_ELIM_THM] THEN
    REPLICATE_TAC 2 (GEN_REWRITE_TAC I [CONJ_ASSOC]) THEN CONJ_TAC THENL
     [MESON_TAC[subgroup_of]; ALL_TAC] THEN
    REPEAT STRIP_TAC THEN
    REPEAT(FIRST_X_ASSUM(MP_TAC o SPEC `group_carrier G:A->bool`)) THEN
    REWRITE_TAC[INTER_SUBSET; SUBSET_REFL; CARRIER_SUBGROUP_OF] THEN
    MESON_TAC GROUP_PROPERTIES;
    DISCH_TAC THEN
    ASM_REWRITE_TAC[group_carrier; group_id; group_inv; group_op]]);;

let SUBGROUP_GENERATED_RESTRICT = prove
 (`!G s:A->bool.
        subgroup_generated G s =
        subgroup_generated G (group_carrier G INTER s)`,
  REWRITE_TAC[subgroup_generated; SET_RULE `g INTER g INTER s = g INTER s`]);;

let SUBGROUP_SUBGROUP_GENERATED = prove
 (`!G s:A->bool. group_carrier(subgroup_generated G s) subgroup_of G`,
  REPEAT GEN_TAC THEN REWRITE_TAC[SUBGROUP_GENERATED] THEN
  MATCH_MP_TAC SUBGROUP_OF_INTERS THEN
  SIMP_TAC[GSYM MEMBER_NOT_EMPTY; IN_ELIM_THM] THEN
  EXISTS_TAC `group_carrier G:A->bool` THEN
  REWRITE_TAC[CARRIER_SUBGROUP_OF; INTER_SUBSET]);;

let SUBGROUP_GENERATED_MONO = prove
 (`!G s t:A->bool.
        s SUBSET t
        ==> group_carrier(subgroup_generated G s) SUBSET
            group_carrier(subgroup_generated G t)`,
  REWRITE_TAC[SUBGROUP_GENERATED] THEN SET_TAC[]);;

let SUBGROUP_GENERATED_MINIMAL = prove
 (`!G h s:A->bool.
        s SUBSET h /\ h subgroup_of G
        ==> group_carrier(subgroup_generated G s) SUBSET h`,
  REWRITE_TAC[SUBGROUP_GENERATED; INTERS_GSPEC] THEN SET_TAC[]);;

let SUBGROUP_GENERATED_INDUCT = prove
 (`!G P s:A->bool.
        (!x. x IN group_carrier G /\ x IN s ==> P x) /\
        P(group_id G) /\
        (!x. P x ==> P(group_inv G x)) /\
        (!x y. P x /\ P y ==> P(group_op G x y))
        ==> !x. x IN group_carrier(subgroup_generated G s) ==> P x`,
  REPEAT GEN_TAC THEN REWRITE_TAC[GSYM IN_INTER] THEN
  ONCE_REWRITE_TAC[SUBGROUP_GENERATED_RESTRICT] THEN MP_TAC(SET_RULE
    `group_carrier G INTER (s:A->bool) SUBSET group_carrier G`) THEN
  SPEC_TAC(`group_carrier G INTER (s:A->bool)`,`s:A->bool`) THEN
  GEN_TAC THEN DISCH_TAC THEN STRIP_TAC THEN
  MP_TAC(ISPECL [`G:A group`; `{x:A | x IN group_carrier G /\ P x}`;
                 `s:A->bool`] SUBGROUP_GENERATED_MINIMAL) THEN
  ANTS_TAC THENL [ALL_TAC; SET_TAC[]] THEN
  CONJ_TAC THENL [ASM SET_TAC[]; ALL_TAC] THEN
  ASM_SIMP_TAC[subgroup_of; IN_ELIM_THM; SUBSET; GROUP_OP; GROUP_INV;
               GROUP_ID]);;

let GROUP_CARRIER_SUBGROUP_GENERATED_SUBSET = prove
 (`!G h:A->bool.
        group_carrier (subgroup_generated G h) SUBSET group_carrier G`,
  REPEAT GEN_TAC THEN REWRITE_TAC[SUBGROUP_GENERATED] THEN
  MATCH_MP_TAC(SET_RULE `a IN s ==> INTERS s SUBSET a`) THEN
  REWRITE_TAC[IN_ELIM_THM; CARRIER_SUBGROUP_OF; INTER_SUBSET]);;

let SUBGROUP_GENERATED_SUBSET_CARRIER = prove
 (`!G h:A->bool.
     group_carrier G INTER h SUBSET group_carrier(subgroup_generated G h)`,
  REWRITE_TAC[subgroup_of; SUBGROUP_GENERATED; SUBSET_INTERS] THEN SET_TAC[]);;

let CARRIER_SUBGROUP_GENERATED_SUBGROUP = prove
 (`!G h:A->bool.
        h subgroup_of G ==> group_carrier (subgroup_generated G h) = h`,
  REWRITE_TAC[subgroup_of; SUBGROUP_GENERATED; INTERS_GSPEC] THEN
  REPEAT GEN_TAC THEN SIMP_TAC[SET_RULE `h SUBSET g ==> g INTER h = h`] THEN
  STRIP_TAC THEN MATCH_MP_TAC SUBSET_ANTISYM THEN
  CONJ_TAC THENL [GEN_REWRITE_TAC I [SUBSET]; ASM SET_TAC[]] THEN
  X_GEN_TAC `x:A` THEN REWRITE_TAC[IN_ELIM_THM] THEN
  DISCH_THEN(MP_TAC o SPEC `h:A->bool`) THEN ASM_REWRITE_TAC[SUBSET_REFL]);;

let SUBGROUP_GENERATED_GROUP_CARRIER = prove
 (`!G:A group. subgroup_generated G (group_carrier G) = G`,
  GEN_TAC THEN REWRITE_TAC[GROUPS_EQ] THEN
  SIMP_TAC[CARRIER_SUBGROUP_GENERATED_SUBGROUP; CARRIER_SUBGROUP_OF] THEN
  REWRITE_TAC[SUBGROUP_GENERATED]);;

let SUBGROUP_OF_SUBGROUP_GENERATED = prove
 (`!G g h:A->bool.
        g subgroup_of G /\ g SUBSET h
        ==> g subgroup_of (subgroup_generated G h)`,
  SIMP_TAC[subgroup_of; SUBGROUP_GENERATED; SUBSET_INTERS] THEN SET_TAC[]);;

let SUBGROUP_GENERATED_SUBSET_CARRIER_SUBSET = prove
 (`!G s:A->bool.
        s SUBSET group_carrier G
        ==> s SUBSET group_carrier(subgroup_generated G s)`,
  MESON_TAC[SUBGROUP_GENERATED_SUBSET_CARRIER;
            SET_RULE `s SUBSET t <=> t INTER s = s`]);;

let SUBGROUP_GENERATED_INC = prove
 (`!G s x:A.
        s SUBSET group_carrier G /\ x IN s
        ==> x IN group_carrier(subgroup_generated G s)`,
  REWRITE_TAC[IMP_CONJ; RIGHT_FORALL_IMP_THM; GSYM SUBSET] THEN
  REWRITE_TAC[SUBGROUP_GENERATED_SUBSET_CARRIER_SUBSET]);;

let SUBGROUP_OF_SUBGROUP_GENERATED_REV = prove
 (`!G g h:A->bool.
        g subgroup_of (subgroup_generated G h)
        ==> g subgroup_of G`,
  SIMP_TAC[subgroup_of; CONJUNCT2 SUBGROUP_GENERATED] THEN
  MESON_TAC[GROUP_CARRIER_SUBGROUP_GENERATED_SUBSET; SUBSET_TRANS]);;

let TRIVIAL_GROUP_SUBGROUP_GENERATED = prove
 (`!G s:A->bool.
        trivial_group G ==> trivial_group(subgroup_generated G s)`,
  REPEAT GEN_TAC THEN REWRITE_TAC[TRIVIAL_GROUP_ALT] THEN
  MESON_TAC[SUBSET_TRANS; GROUP_CARRIER_SUBGROUP_GENERATED_SUBSET]);;

let TRIVIAL_GROUP_SUBGROUP_GENERATED_TRIVIAL = prove
 (`!G s:A->bool.
        s SUBSET {group_id G} ==> trivial_group(subgroup_generated G s)`,
  REPEAT STRIP_TAC THEN
  REWRITE_TAC[TRIVIAL_GROUP_ALT; SUBGROUP_GENERATED] THEN
  EXISTS_TAC `group_id G:A` THEN
  MATCH_MP_TAC INTERS_SUBSET_STRONG THEN
  EXISTS_TAC `{group_id G:A}` THEN
  REWRITE_TAC[IN_ELIM_THM; TRIVIAL_SUBGROUP_OF] THEN ASM SET_TAC[]);;

(* ------------------------------------------------------------------------- *)
(* Direct products and sums.                                                 *)
(* ------------------------------------------------------------------------- *)

let prod_group = new_definition
 `prod_group (G:A group) (G':B group) =
        group((group_carrier G) CROSS (group_carrier G'),
              (group_id G,group_id G'),
              (\(x,x'). group_inv G x,group_inv G' x'),
              (\(x,x') (y,y'). group_op G x y,group_op G' x' y'))`;;

let PROD_GROUP = prove
 (`(!(G:A group) (G':B group).
        group_carrier (prod_group G G') =
        (group_carrier G) CROSS (group_carrier G')) /\
   (!(G:A group) (G':B group).
        group_id (prod_group G G') = (group_id G,group_id G')) /\
   (!(G:A group) (G':B group).
        group_inv (prod_group G G') =
          \(x,x'). group_inv G x,group_inv G' x') /\
   (!(G:A group) (G':B group).
        group_op (prod_group G G') =
          \(x,x') (y,y'). group_op G x y,group_op G' x' y')`,
  REWRITE_TAC[AND_FORALL_THM] THEN REPEAT GEN_TAC THEN
  MP_TAC(fst(EQ_IMP_RULE
   (ISPEC(rand(rand(snd(strip_forall(concl prod_group)))))
   (CONJUNCT2 group_tybij)))) THEN
  REWRITE_TAC[GSYM prod_group] THEN ANTS_TAC THENL
   [REWRITE_TAC[FORALL_PAIR_THM; IN_CROSS; PAIR_EQ] THEN
    SIMP_TAC GROUP_PROPERTIES;
    DISCH_TAC THEN
    ASM_REWRITE_TAC[group_carrier; group_id; group_inv; group_op]]);;

let product_group = new_definition
 `product_group k (G:K->A group) =
        group(cartesian_product k (\i. group_carrier(G i)),
              RESTRICTION k (\i. group_id (G i)),
              (\x. RESTRICTION k (\i. group_inv (G i) (x i))),
              (\x y. RESTRICTION k (\i. group_op (G i) (x i) (y i))))`;;

let PRODUCT_GROUP = prove
 (`(!k (G:K->A group).
        group_carrier(product_group k G) =
          cartesian_product k (\i. group_carrier(G i))) /\
   (!k (G:K->A group).
        group_id (product_group k G) =
          RESTRICTION k (\i. group_id (G i))) /\
   (!k (G:K->A group).
        group_inv (product_group k G) =
          \x. RESTRICTION k (\i. group_inv (G i) (x i))) /\
   (!k (G:K->A group).
        group_op (product_group k G) =
          (\x y. RESTRICTION k (\i. group_op (G i) (x i) (y i))))`,
  REWRITE_TAC[AND_FORALL_THM] THEN REPEAT GEN_TAC THEN
  MP_TAC(fst(EQ_IMP_RULE
   (ISPEC(rand(rand(snd(strip_forall(concl product_group)))))
   (CONJUNCT2 group_tybij)))) THEN
  REWRITE_TAC[GSYM product_group] THEN ANTS_TAC THENL
   [REWRITE_TAC[cartesian_product; RESTRICTION; EXTENSIONAL; IN_ELIM_THM] THEN
    REWRITE_TAC[FUN_EQ_THM; RESTRICTION] THEN
    REPEAT STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
    REPEAT(COND_CASES_TAC THEN ASM_REWRITE_TAC[]) THEN
    ASM_SIMP_TAC GROUP_PROPERTIES;
    DISCH_TAC THEN
    ASM_REWRITE_TAC[group_carrier; group_id; group_inv; group_op]]);;

let SUBGROUP_SUM_GROUP = prove
 (`!k (G:K->A group).
    {x | x IN cartesian_product k (\i. group_carrier(G i)) /\
         FINITE {i | i IN k /\ ~(x i = group_id(G i))}}
    subgroup_of product_group k G`,
  REWRITE_TAC[subgroup_of; PRODUCT_GROUP; SUBSET_RESTRICT] THEN
  REWRITE_TAC[RESTRICTION; cartesian_product; IN_ELIM_THM; EXTENSIONAL] THEN
  ONCE_REWRITE_TAC[TAUT `p /\ ~q <=> ~(p ==> q)`] THEN
  SIMP_TAC[GROUP_ID; GROUP_INV_EQ_ID; GROUP_INV; GROUP_OP] THEN
  REWRITE_TAC[EMPTY_GSPEC; FINITE_EMPTY] THEN REPEAT GEN_TAC THEN
  DISCH_THEN(CONJUNCTS_THEN(CONJUNCTS_THEN2 STRIP_ASSUME_TAC MP_TAC)) THEN
  REWRITE_TAC[IMP_IMP; GSYM FINITE_UNION] THEN
  MATCH_MP_TAC(REWRITE_RULE[IMP_CONJ_ALT] FINITE_SUBSET) THEN
  REWRITE_TAC[NOT_IMP; SUBSET; IN_ELIM_THM; IN_UNION] THEN
  GEN_TAC THEN GEN_REWRITE_TAC I [GSYM CONTRAPOS_THM] THEN
  REWRITE_TAC[DE_MORGAN_THM] THEN STRIP_TAC THEN
  REWRITE_TAC[TAUT `~p \/ q <=> p ==> q`] THEN
  ASM_SIMP_TAC[GROUP_OP_LID; GROUP_ID]);;

let sum_group = new_definition
  `sum_group k (G:K->A group) =
        subgroup_generated
         (product_group k G)
         {x | x IN cartesian_product k (\i. group_carrier(G i)) /\
              FINITE {i | i IN k /\ ~(x i = group_id(G i))}}`;;

let SUM_GROUP = prove
 (`(!k (G:K->A group).
        group_carrier(sum_group k G) =
          {x | x IN cartesian_product k (\i. group_carrier(G i)) /\
               FINITE {i | i IN k /\ ~(x i = group_id(G i))}}) /\
   (!k (G:K->A group).
        group_id (sum_group k G) =
          RESTRICTION k (\i. group_id (G i))) /\
   (!k (G:K->A group).
        group_inv (sum_group k G) =
          \x. RESTRICTION k (\i. group_inv (G i) (x i))) /\
   (!k (G:K->A group).
        group_op (sum_group k G) =
          (\x y. RESTRICTION k (\i. group_op (G i) (x i) (y i))))`,
  SIMP_TAC[sum_group; SUBGROUP_SUM_GROUP;
           CARRIER_SUBGROUP_GENERATED_SUBGROUP] THEN
  REWRITE_TAC[SUBGROUP_GENERATED; PRODUCT_GROUP]);;

(* ------------------------------------------------------------------------- *)
(* Homomorphisms etc.                                                        *)
(* ------------------------------------------------------------------------- *)

let group_homomorphism = new_definition
 `group_homomorphism (G,G') (f:A->B) <=>
        IMAGE f (group_carrier G) SUBSET group_carrier G' /\
        f (group_id G) = group_id G' /\
        (!x. x IN group_carrier G
             ==> f(group_inv G x) = group_inv G' (f x)) /\
        (!x y. x IN group_carrier G /\ y IN group_carrier G
               ==> f(group_op G x y) = group_op G' (f x) (f y))`;;

let group_monomorphism = new_definition
 `group_monomorphism (G,G') (f:A->B) <=>
        group_homomorphism (G,G') f /\
        !x y. x IN group_carrier G /\ y IN group_carrier G /\ f x = f y
             ==> x = y`;;

let group_epimorphism = new_definition
 `group_epimorphism (G,G') (f:A->B) <=>
        group_homomorphism (G,G') f /\
        IMAGE f (group_carrier G) = group_carrier G'`;;

let group_endomorphism = new_definition
 `group_endomorphism G (f:A->A) <=> group_homomorphism (G,G) f`;;

let group_isomorphisms = new_definition
 `group_isomorphisms (G,G') ((f:A->B),g) <=>
        group_homomorphism (G,G') f /\
        group_homomorphism (G',G) g /\
        (!x. x IN group_carrier G ==> g(f x) = x) /\
        (!y. y IN group_carrier G' ==> f(g y) = y)`;;

let group_isomorphism = new_definition
 `group_isomorphism (G,G') (f:A->B) <=> ?g. group_isomorphisms (G,G') (f,g)`;;

let group_automorphism = new_definition
 `group_automorphism G (f:A->A) <=> group_isomorphism (G,G) f`;;

let GROUP_HOMOMORPHISM_EQ = prove
 (`!G H (f:A->B) f'.
        group_homomorphism(G,H) f /\
        (!x. x IN group_carrier G ==> f' x = f x)
        ==> group_homomorphism (G,H) f'`,
  REWRITE_TAC[group_homomorphism; SUBSET; FORALL_IN_IMAGE] THEN
  SIMP_TAC[GROUP_ID; GROUP_INV; GROUP_OP]);;

let GROUP_MONOMORPHISM_EQ = prove
 (`!G H (f:A->B) f'.
        group_monomorphism(G,H) f /\
        (!x. x IN group_carrier G ==> f' x = f x)
        ==> group_monomorphism (G,H) f'`,
  REWRITE_TAC[group_monomorphism; group_homomorphism; SUBSET] THEN
  SIMP_TAC[FORALL_IN_IMAGE; GROUP_ID; GROUP_INV; GROUP_OP] THEN
  MESON_TAC[]);;

let GROUP_EPIMORPHISM_EQ = prove
 (`!G H (f:A->B) f'.
        group_epimorphism(G,H) f /\
        (!x. x IN group_carrier G ==> f' x = f x)
        ==> group_epimorphism (G,H) f'`,
  REWRITE_TAC[group_epimorphism; group_homomorphism; SUBSET] THEN
  SIMP_TAC[FORALL_IN_IMAGE; GROUP_ID; GROUP_INV; GROUP_OP] THEN
  SET_TAC[]);;

let GROUP_ENDOMORPHISM_EQ = prove
 (`!G (f:A->A) f'.
        group_endomorphism G f /\
        (!x. x IN group_carrier G ==> f' x = f x)
        ==> group_endomorphism G f'`,
  REWRITE_TAC[group_endomorphism; GROUP_HOMOMORPHISM_EQ]);;

let GROUP_ISOMORPHISMS_EQ = prove
 (`!G H (f:A->B) g.
        group_isomorphisms(G,H) (f,g) /\
        (!x. x IN group_carrier G ==> f' x = f x) /\
        (!y. y IN group_carrier H ==> g' y = g y)
        ==> group_isomorphisms(G,H) (f',g')`,
  SIMP_TAC[group_isomorphisms; group_homomorphism; SUBSET] THEN
  SIMP_TAC[FORALL_IN_IMAGE; GROUP_ID; GROUP_INV; GROUP_OP] THEN
  SET_TAC[]);;

let GROUP_ISOMORPHISM_EQ = prove
 (`!G H (f:A->B) f'.
        group_isomorphism(G,H) f /\
        (!x. x IN group_carrier G ==> f' x = f x)
        ==> group_isomorphism (G,H) f'`,
  REPEAT GEN_TAC THEN DISCH_THEN(CONJUNCTS_THEN2 MP_TAC ASSUME_TAC) THEN
  REWRITE_TAC[group_isomorphism] THEN MATCH_MP_TAC MONO_EXISTS THEN
  ASM_MESON_TAC[GROUP_ISOMORPHISMS_EQ]);;

let GROUP_AUTOMORPHISM_EQ = prove
 (`!G (f:A->A) f'.
        group_automorphism G f /\
        (!x. x IN group_carrier G ==> f' x = f x)
        ==> group_automorphism G f'`,
  REWRITE_TAC[group_automorphism; GROUP_ISOMORPHISM_EQ]);;

let GROUP_ISOMORPHISMS_SYM = prove
 (`!G G' (f:A->B) g.
        group_isomorphisms (G,G') (f,g) <=> group_isomorphisms(G',G) (g,f)`,
  REWRITE_TAC[group_isomorphisms] THEN MESON_TAC[]);;

let GROUP_HOMOMORPHISM = prove
 (`!G G' f:A->B.
        group_homomorphism (G,G') (f:A->B) <=>
        IMAGE f (group_carrier G) SUBSET group_carrier G' /\
        (!x y. x IN group_carrier G /\ y IN group_carrier G
               ==> f(group_op G x y) = group_op G' (f x) (f y))`,
  REPEAT GEN_TAC THEN REWRITE_TAC[group_homomorphism] THEN
  EQ_TAC THEN STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  RULE_ASSUM_TAC(REWRITE_RULE[SUBSET; FORALL_IN_IMAGE]) THEN
  MATCH_MP_TAC(TAUT `p /\ (p ==> q) ==> p /\ q`) THEN CONJ_TAC THENL
   [FIRST_X_ASSUM(MP_TAC o SPECL [`group_id G:A`; `group_id G:A`]) THEN
    SIMP_TAC[GROUP_ID; GROUP_OP_LID] THEN
    GEN_REWRITE_TAC LAND_CONV [EQ_SYM_EQ] THEN
    ASM_MESON_TAC[GROUP_LID_UNIQUE; GROUP_ID];
    REPEAT STRIP_TAC THEN CONV_TAC SYM_CONV THEN
    MATCH_MP_TAC GROUP_LINV_UNIQUE THEN
    FIRST_X_ASSUM(MP_TAC o SPECL [`x:A`; `group_inv G x:A`]) THEN
    ASM_SIMP_TAC[GROUP_INV; GROUP_OP_RINV]]);;

let GROUP_HOMOMORPHISM_DIV = prove
 (`!G G' (f:A->B).
        group_homomorphism(G,G') f
        ==> !x y. x IN group_carrier G /\ y IN group_carrier G
                  ==> f(group_div G x y) = group_div G' (f x) (f y)`,
  REWRITE_TAC[group_homomorphism; group_div] THEN
  MESON_TAC[GROUP_OP; GROUP_INV]);;

let GROUP_HOMOMORPHISM_ID = prove
 (`!G:A group. group_homomorphism (G,G) (\x. x)`,
  REWRITE_TAC[group_homomorphism; IMAGE_ID; SUBSET_REFL]);;

let GROUP_MONOMORPHISM_ID = prove
 (`!G:A group. group_monomorphism (G,G) (\x. x)`,
  SIMP_TAC[group_monomorphism; GROUP_HOMOMORPHISM_ID]);;

let GROUP_EPIMORPHISM_ID = prove
 (`!G:A group. group_epimorphism (G,G) (\x. x)`,
  SIMP_TAC[group_epimorphism; GROUP_HOMOMORPHISM_ID; IMAGE_ID]);;

let GROUP_ISOMORPHISMS_ID = prove
 (`!G:A group. group_isomorphisms (G,G) ((\x. x),(\x. x))`,
  REWRITE_TAC[group_isomorphisms; GROUP_HOMOMORPHISM_ID]);;

let GROUP_ISOMORPHISM_ID = prove
 (`!G:A group. group_isomorphism (G,G) (\x. x)`,
  REWRITE_TAC[group_isomorphism] THEN MESON_TAC[GROUP_ISOMORPHISMS_ID]);;

let GROUP_HOMOMORPHISM_COMPOSE = prove
 (`!G1 G2 G3 (f:A->B) (g:B->C).
        group_homomorphism(G1,G2) f /\ group_homomorphism(G2,G3) g
        ==> group_homomorphism(G1,G3) (g o f)`,
  SIMP_TAC[group_homomorphism; SUBSET; FORALL_IN_IMAGE; IMAGE_o; o_THM]);;

let GROUP_MONOMORPHISM_COMPOSE = prove
 (`!G1 G2 G3 (f:A->B) (g:B->C).
        group_monomorphism(G1,G2) f /\ group_monomorphism(G2,G3) g
        ==> group_monomorphism(G1,G3) (g o f)`,
  REWRITE_TAC[group_monomorphism; group_homomorphism; INJECTIVE_ON_ALT] THEN
  SIMP_TAC[SUBSET; FORALL_IN_IMAGE; IMAGE_o; o_THM]);;

let GROUP_MONOMORPHISM_COMPOSE_REV = prove
 (`!(f:A->B) (g:B->C) A B C.
        group_homomorphism(A,B) f /\ group_homomorphism(B,C) g /\
        group_monomorphism(A,C) (g o f)
        ==> group_monomorphism(A,B) f`,
  REWRITE_TAC[group_monomorphism; o_THM] THEN MESON_TAC[]);;

let GROUP_EPIMORPHISM_COMPOSE = prove
 (`!G1 G2 G3 (f:A->B) (g:B->C).
        group_epimorphism(G1,G2) f /\ group_epimorphism(G2,G3) g
        ==> group_epimorphism(G1,G3) (g o f)`,
  SIMP_TAC[group_epimorphism; IMAGE_o] THEN
  MESON_TAC[GROUP_HOMOMORPHISM_COMPOSE]);;

let GROUP_EPIMORPHISM_COMPOSE_REV = prove
 (`!(f:A->B) (g:B->C) A B C.
        group_homomorphism(A,B) f /\ group_homomorphism(B,C) g /\
        group_epimorphism(A,C) (g o f)
        ==> group_epimorphism(B,C) g`,
  REWRITE_TAC[group_epimorphism; group_homomorphism; o_THM; IMAGE_o] THEN
  SET_TAC[]);;

let GROUP_MONOMORPHISM_LEFT_INVERTIBLE = prove
 (`!G H (f:A->B) g.
        group_homomorphism(G,H) f /\
        (!x. x IN group_carrier G ==> g(f x) = x)
        ==> group_monomorphism (G,H) f`,
  REWRITE_TAC[INJECTIVE_ON_LEFT_INVERSE; group_monomorphism] THEN
  MESON_TAC[]);;

let GROUP_EPIMORPHISM_RIGHT_INVERTIBLE = prove
 (`!G H (f:A->B) g.
        group_homomorphism(G,H) f /\
        group_homomorphism(H,G) g /\
        (!x. x IN group_carrier G ==> g(f x) = x)
        ==> group_epimorphism (H,G) g`,
  SIMP_TAC[group_epimorphism] THEN REWRITE_TAC[group_homomorphism] THEN
  SET_TAC[]);;

let GROUP_HOMOMORPHISM_INTO_SUBGROUP = prove
 (`!G G' h (f:A->B).
        group_homomorphism (G,G') f /\ IMAGE f (group_carrier G) SUBSET h
        ==> group_homomorphism (G,subgroup_generated G' h) f`,
  REPEAT GEN_TAC THEN SIMP_TAC[group_homomorphism; SUBGROUP_GENERATED] THEN
  REWRITE_TAC[INTERS_GSPEC] THEN SET_TAC[]);;

let GROUP_HOMOMORPHISM_INTO_SUBGROUP_EQ_GEN = prove
 (`!(f:A->B) G H s.
      group_homomorphism(G,subgroup_generated H s) f <=>
      group_homomorphism(G,H) f /\
      IMAGE f (group_carrier G) SUBSET group_carrier(subgroup_generated H s)`,
  REPEAT GEN_TAC THEN REWRITE_TAC[group_homomorphism] THEN
  MP_TAC(ISPECL [`H:B group`; `s:B->bool`]
    GROUP_CARRIER_SUBGROUP_GENERATED_SUBSET) THEN
  REWRITE_TAC[SUBGROUP_GENERATED] THEN SET_TAC[]);;

let GROUP_HOMOMORPHISM_INTO_SUBGROUP_EQ = prove
 (`!G G' h (f:A->B).
        h subgroup_of G'
        ==> (group_homomorphism (G,subgroup_generated G' h) f <=>
             group_homomorphism (G,G') f /\
             IMAGE f (group_carrier G) SUBSET h)`,
  SIMP_TAC[GROUP_HOMOMORPHISM_INTO_SUBGROUP_EQ_GEN;
           CARRIER_SUBGROUP_GENERATED_SUBGROUP]);;

let GROUP_HOMOMORPHISM_FROM_SUBGROUP_GENERATED = prove
 (`!(f:A->B) G H s.
        group_homomorphism (G,H) f
        ==> group_homomorphism(subgroup_generated G s,H) f`,
  REPEAT GEN_TAC THEN REWRITE_TAC[group_homomorphism] THEN
  MP_TAC(ISPECL [`G:A group`; `s:A->bool`]
        GROUP_CARRIER_SUBGROUP_GENERATED_SUBSET) THEN
  SIMP_TAC[SUBSET; SUBGROUP_GENERATED] THEN SET_TAC[]);;

let GROUP_ISOMORPHISM = prove
 (`!G G' f:A->B.
      group_isomorphism (G,G') (f:A->B) <=>
      group_homomorphism (G,G') f /\
      IMAGE f (group_carrier G) = group_carrier G' /\
      (!x y. x IN group_carrier G /\ y IN group_carrier G /\ f x = f y
             ==> x = y)`,
  REPEAT GEN_TAC THEN
  REWRITE_TAC[group_isomorphism; group_isomorphisms; group_homomorphism] THEN
  REWRITE_TAC[INJECTIVE_ON_LEFT_INVERSE; RIGHT_AND_EXISTS_THM] THEN
  AP_TERM_TAC THEN ABS_TAC THEN
  EQ_TAC THEN STRIP_TAC THEN ASM_REWRITE_TAC[] THENL
   [ASM SET_TAC[]; ALL_TAC] THEN
  SUBST1_TAC(SYM(ASSUME
    `IMAGE (f:A->B) (group_carrier G) = group_carrier G'`)) THEN
  REWRITE_TAC[SUBSET; FORALL_IN_IMAGE; FORALL_IN_IMAGE_2] THEN
  ASM_SIMP_TAC[] THEN ASM_MESON_TAC(GROUP_PROPERTIES));;

let GROUP_MONOMORPHISM_EPIMORPHISM = prove
 (`!G G' f:A->B.
        group_monomorphism (G,G') f /\ group_epimorphism (G,G') f <=>
        group_isomorphism (G,G') f`,
  REWRITE_TAC[GROUP_ISOMORPHISM; group_monomorphism; group_epimorphism] THEN
  MESON_TAC[]);;

let GROUP_ISOMORPHISMS_COMPOSE = prove
 (`!G1 G2 G3 (f1:A->B) (f2:B->C) g1 g2.
        group_isomorphisms(G1,G2) (f1,g1) /\ group_isomorphisms(G2,G3) (f2,g2)
        ==> group_isomorphisms(G1,G3) (f2 o f1,g1 o g2)`,
  SIMP_TAC[group_isomorphisms; group_homomorphism;
           SUBSET; FORALL_IN_IMAGE; IMAGE_o; o_THM]);;

let GROUP_ISOMORPHISM_COMPOSE = prove
 (`!G1 G2 G3 (f:A->B) (g:B->C).
        group_isomorphism(G1,G2) f /\ group_isomorphism(G2,G3) g
        ==> group_isomorphism(G1,G3) (g o f)`,
  REWRITE_TAC[group_isomorphism] THEN MESON_TAC[GROUP_ISOMORPHISMS_COMPOSE]);;

let GROUP_ISOMORPHISM_COMPOSE_REV = prove
 (`!(f:A->B) (g:B->C) A B C.
        group_homomorphism(A,B) f /\ group_homomorphism(B,C) g /\
        group_isomorphism(A,C) (g o f)
        ==> group_monomorphism(A,B) f /\ group_epimorphism(B,C) g`,
  REWRITE_TAC[GSYM GROUP_MONOMORPHISM_EPIMORPHISM] THEN
  MESON_TAC[GROUP_MONOMORPHISM_COMPOSE_REV; GROUP_EPIMORPHISM_COMPOSE_REV]);;

let GROUP_EPIMORPHISM_ISOMORPHISM_COMPOSE_REV = prove
 (`!(f:A->B) (g:B->C) A B C.
        group_epimorphism (A,B) f /\
        group_homomorphism (B,C) g /\
        group_isomorphism (A,C) (g o f)
        ==> group_isomorphism (A,B) f /\ group_isomorphism (B,C) g`,
  REPEAT GEN_TAC THEN STRIP_TAC THEN
  MATCH_MP_TAC(TAUT `p /\ (p ==> q) ==> p /\ q`) THEN CONJ_TAC THENL
   [ASM_MESON_TAC[GROUP_ISOMORPHISM_COMPOSE_REV; group_epimorphism;
                  GROUP_MONOMORPHISM_EPIMORPHISM];
    REWRITE_TAC[group_isomorphism; LEFT_IMP_EXISTS_THM] THEN
    X_GEN_TAC `f':B->A` THEN DISCH_TAC THEN
    REWRITE_TAC[GSYM group_isomorphism] THEN
    MATCH_MP_TAC GROUP_ISOMORPHISM_EQ THEN
    EXISTS_TAC `(g:B->C) o f o (f':B->A)` THEN CONJ_TAC THENL
     [REWRITE_TAC[o_ASSOC] THEN MATCH_MP_TAC GROUP_ISOMORPHISM_COMPOSE THEN
      ASM_MESON_TAC[GROUP_ISOMORPHISMS_SYM; group_isomorphism];
      RULE_ASSUM_TAC(REWRITE_RULE
       [group_isomorphisms; group_homomorphism; SUBSET; FORALL_IN_IMAGE]) THEN
      ASM_SIMP_TAC[o_THM]]]);;

let GROUP_MONOMORPHISM_ISOMORPHISM_COMPOSE_REV = prove
 (`!(f:A->B) (g:B->C) A B C.
        group_homomorphism (A,B) f /\
        group_monomorphism (B,C) g /\
        group_isomorphism (A,C) (g o f)
        ==> group_isomorphism (A,B) f /\ group_isomorphism (B,C) g`,
  REPEAT GEN_TAC THEN STRIP_TAC THEN
  MATCH_MP_TAC(TAUT `q /\ (q ==> p) ==> p /\ q`) THEN CONJ_TAC THENL
   [ASM_MESON_TAC[GROUP_ISOMORPHISM_COMPOSE_REV; group_monomorphism;
                  GROUP_MONOMORPHISM_EPIMORPHISM];
    REWRITE_TAC[group_isomorphism; LEFT_IMP_EXISTS_THM] THEN
    X_GEN_TAC `g':C->B` THEN DISCH_TAC THEN
    REWRITE_TAC[GSYM group_isomorphism] THEN
    MATCH_MP_TAC GROUP_ISOMORPHISM_EQ THEN
    EXISTS_TAC `(g':C->B) o g o (f:A->B)` THEN CONJ_TAC THENL
     [MATCH_MP_TAC GROUP_ISOMORPHISM_COMPOSE THEN
      ASM_MESON_TAC[GROUP_ISOMORPHISMS_SYM; group_isomorphism];
      RULE_ASSUM_TAC(REWRITE_RULE
       [group_isomorphisms; group_homomorphism; SUBSET; FORALL_IN_IMAGE]) THEN
      ASM_SIMP_TAC[o_THM]]]);;

let GROUP_ISOMORPHISM_INVERSE = prove
 (`!(f:A->B) g G H.
        group_isomorphism(G,H) f /\
        (!x. x IN group_carrier G ==> g(f x) = x)
        ==> group_isomorphism(H,G) g`,
  REWRITE_TAC[group_isomorphism; group_isomorphisms; group_homomorphism] THEN
  REWRITE_TAC[SUBSET; FORALL_IN_IMAGE] THEN REPEAT STRIP_TAC THEN
  EXISTS_TAC `f:A->B` THEN ASM_SIMP_TAC[] THEN
  SUBGOAL_THEN
   `!y. y IN group_carrier H ==> (g:B->A) y IN group_carrier G`
  ASSUME_TAC THENL [ASM_MESON_TAC[]; ALL_TAC] THEN
  SUBGOAL_THEN
   `!y. y IN group_carrier H ==> (f:A->B)(g y) = y`
  ASSUME_TAC THENL [ASM_MESON_TAC[]; ALL_TAC] THEN
  ASM_MESON_TAC[GROUP_ID; GROUP_INV; GROUP_OP]);;

let GROUP_ISOMORPHISMS_OPPOSITE_GROUP = prove
 (`!G:A group.
        group_isomorphisms(G,opposite_group G) (group_inv G,group_inv G)`,
  REWRITE_TAC[group_isomorphisms; group_homomorphism; OPPOSITE_GROUP] THEN
  REWRITE_TAC[SUBSET; FORALL_IN_IMAGE; GROUP_INV_ID] THEN
  SIMP_TAC[GROUP_INV; GROUP_INV_OP; GROUP_INV_INV]);;

let GROUP_HOMOMORPHISM_FROM_TRIVIAL_GROUP = prove
 (`!(f:A->B) G H.
        trivial_group G
        ==> (group_homomorphism(G,H) f <=> f(group_id G) = group_id H)`,
  REPEAT GEN_TAC THEN SIMP_TAC[trivial_group; group_homomorphism] THEN
  ASM_CASES_TAC `(f:A->B)(group_id G) = group_id H` THEN
  ASM_REWRITE_TAC[] THEN DISCH_THEN(K ALL_TAC) THEN
  ASM_SIMP_TAC[IN_SING; GROUP_OP_LID; GROUP_ID; SUBSET; FORALL_IN_IMAGE;
               GROUP_INV_ID]);;

let GROUP_MONOMORPHISM_FROM_TRIVIAL_GROUP = prove
 (`!(f:A->B) G H.
        trivial_group G
        ==> (group_monomorphism (G,H) f <=> group_homomorphism (G,H) f)`,
  REWRITE_TAC[group_monomorphism; trivial_group] THEN SET_TAC[]);;

let GROUP_MONOMORPHISM_TO_TRIVIAL_GROUP = prove
 (`!(f:A->B) G H.
        trivial_group H
        ==> (group_monomorphism (G,H) f <=>
             group_homomorphism (G,H) f /\ trivial_group G)`,
  SIMP_TAC[group_monomorphism; trivial_group; group_homomorphism] THEN
  REPEAT GEN_TAC THEN MP_TAC(ISPEC `G:A group` GROUP_ID) THEN SET_TAC[]);;

let GROUP_EPIMORPHISM_FROM_TRIVIAL_GROUP = prove
 (`!(f:A->B) G H.
        trivial_group G
        ==> (group_epimorphism (G,H) f <=>
             group_homomorphism (G,H) f /\ trivial_group H)`,
  SIMP_TAC[group_epimorphism; trivial_group; group_homomorphism] THEN
  SET_TAC[]);;

let GROUP_EPIMORPHISM_TO_TRIVIAL_GROUP = prove
 (`!(f:A->B) G H.
        trivial_group H
        ==> (group_epimorphism (G,H) f <=>
             group_homomorphism (G,H) f)`,
  REWRITE_TAC[group_epimorphism; trivial_group; group_homomorphism] THEN
  REPEAT GEN_TAC THEN
  MAP_EVERY(MP_TAC o C ISPEC GROUP_ID) [`G:A group`; `H:B group`] THEN
  SET_TAC[]);;

let GROUP_HOMOMORPHISM_PAIRWISE = prove
 (`!(f:A->B#C) G H K.
        group_homomorphism(G,prod_group H K) f <=>
        group_homomorphism(G,H) (FST o f) /\
        group_homomorphism(G,K) (SND o f)`,
  REWRITE_TAC[group_homomorphism; PROD_GROUP] THEN
  REWRITE_TAC[FORALL_PAIR_FUN_THM; SUBSET; FORALL_IN_IMAGE] THEN
  REWRITE_TAC[o_DEF; IN_CROSS; PAIR_EQ] THEN MESON_TAC[]);;

let GROUP_HOMOMORPHISM_PAIRED = prove
 (`!(f:A->B) (g:A->C) G H K.
        group_homomorphism(G,prod_group H K) (\x. f x,g x) <=>
        group_homomorphism(G,H) f /\
        group_homomorphism(G,K) g`,
  REWRITE_TAC[GROUP_HOMOMORPHISM_PAIRWISE; o_DEF; ETA_AX]);;

let GROUP_HOMOMORPHISM_PAIRED2 = prove
 (`!(f:A->B) (g:C->D) G H G' H'.
        group_homomorphism(prod_group G H,prod_group G' H')
                (\(x,y). f x,g y) <=>
        group_homomorphism(G,G') f /\ group_homomorphism(H,H') g`,
  REWRITE_TAC[group_homomorphism; PROD_GROUP; SUBSET; FORALL_IN_IMAGE] THEN
  REWRITE_TAC[PROD_GROUP; FORALL_PAIR_THM; IN_CROSS; PAIR_EQ] THEN
  MESON_TAC[GROUP_ID]);;

let GROUP_ISOMORPHISMS_PAIRED2 = prove
 (`!(f:A->B) (g:C->D) f' g' G H G' H'.
        group_isomorphisms(prod_group G H,prod_group G' H')
                ((\(x,y). f x,g y),(\(x,y). f' x,g' y)) <=>
        group_isomorphisms(G,G') (f,f') /\
        group_isomorphisms(H,H') (g,g')`,
  REWRITE_TAC[group_isomorphisms; GROUP_HOMOMORPHISM_PAIRED2] THEN
  REWRITE_TAC[PROD_GROUP; FORALL_IN_CROSS; PAIR_EQ] THEN
  MESON_TAC[GROUP_ID]);;

let GROUP_ISOMORPHISM_PAIRED2 = prove
 (`!(f:A->B) (g:C->D) G H G' H'.
        group_isomorphism(prod_group G H,prod_group G' H')
                (\(x,y). f x,g y) <=>
        group_isomorphism(G,G') f /\ group_isomorphism(H,H') g`,
  REWRITE_TAC[GROUP_ISOMORPHISM; GROUP_HOMOMORPHISM_PAIRED2] THEN
  REWRITE_TAC[PROD_GROUP; FORALL_PAIR_THM; IN_CROSS; IMAGE_PAIRED_CROSS] THEN
  REWRITE_TAC[CROSS_EQ; IMAGE_EQ_EMPTY; GROUP_CARRIER_NONEMPTY; PAIR_EQ] THEN
  MESON_TAC[GROUP_ID]);;

let GROUP_HOMOMORPHISM_OF_FST = prove
 (`!(f:A->C) A (B:B group) C.
        group_homomorphism (prod_group A B,C) (f o FST) <=>
        group_homomorphism (A,C) f`,
  REWRITE_TAC[group_homomorphism; SUBSET; FORALL_IN_IMAGE; PROD_GROUP] THEN
  REWRITE_TAC[FORALL_PAIR_THM; IN_CROSS; o_DEF] THEN MESON_TAC[GROUP_ID]);;

let GROUP_HOMOMORPHISM_OF_SND = prove
 (`!(f:B->C) (A:A group) B C.
        group_homomorphism (prod_group A B,C) (f o SND) <=>
        group_homomorphism (B,C) f`,
  REWRITE_TAC[group_homomorphism; SUBSET; FORALL_IN_IMAGE; PROD_GROUP] THEN
  REWRITE_TAC[FORALL_PAIR_THM; IN_CROSS; o_DEF] THEN MESON_TAC[GROUP_ID]);;

(* ------------------------------------------------------------------------- *)
(* Relation of isomorphism.                                                  *)
(* ------------------------------------------------------------------------- *)

parse_as_infix("isomorphic_group",(12, "right"));;

let isomorphic_group = new_definition
 `G isomorphic_group G' <=> ?f:A->B. group_isomorphism (G,G') f`;;

let GROUP_ISOMORPHISM_IMP_ISOMORPHIC = prove
 (`!G H f:A->B. group_isomorphism (G,H) f ==> G isomorphic_group H`,
  REWRITE_TAC[isomorphic_group] THEN MESON_TAC[]);;

let ISOMORPHIC_GROUP_REFL = prove
 (`!G:A group. G isomorphic_group G`,
  GEN_TAC THEN REWRITE_TAC[isomorphic_group] THEN EXISTS_TAC `\x:A. x` THEN
  REWRITE_TAC[GROUP_ISOMORPHISM_ID]);;

let ISOMORPHIC_GROUP_SYM = prove
 (`!(G:A group) (H:B group). G isomorphic_group H <=> H isomorphic_group G`,
  REWRITE_TAC[isomorphic_group; group_isomorphism] THEN
  MESON_TAC[GROUP_ISOMORPHISMS_SYM]);;

let ISOMORPHIC_GROUP_TRANS = prove
 (`!(G1:A group) (G2:B group) (G3:C group).
        G1 isomorphic_group G2 /\ G2 isomorphic_group G3
        ==> G1 isomorphic_group G3`,
  REWRITE_TAC[isomorphic_group] THEN MESON_TAC[GROUP_ISOMORPHISM_COMPOSE]);;

let ISOMORPHIC_GROUP_OPPOSITE_GROUP = prove
 (`!G:A group. (opposite_group G) isomorphic_group G`,
  ONCE_REWRITE_TAC[ISOMORPHIC_GROUP_SYM] THEN
  REWRITE_TAC[isomorphic_group; group_isomorphism] THEN
  MESON_TAC[GROUP_ISOMORPHISMS_OPPOSITE_GROUP]);;

let ISOMORPHIC_GROUP_TRIVIALITY = prove
 (`!(G:A group) (H:B group).
        G isomorphic_group H ==> (trivial_group G <=> trivial_group H)`,
  REWRITE_TAC[isomorphic_group; TRIVIAL_GROUP; group_isomorphism;
              group_isomorphisms; group_homomorphism] THEN
  SET_TAC[]);;

let ISOMORPHIC_TO_TRIVIAL_GROUP = prove
 (`(!(G:A group) (H:B group).
        trivial_group G ==> (G isomorphic_group H <=> trivial_group H)) /\
   (!(G:A group) (H:B group).
        trivial_group H ==> (G isomorphic_group H <=> trivial_group G))`,
  let lemma = prove
   (`!(G:A group) (H:B group).
        trivial_group G ==> (G isomorphic_group H <=> trivial_group H)`,
    REPEAT STRIP_TAC THEN EQ_TAC THENL
     [ASM_MESON_TAC[ISOMORPHIC_GROUP_TRIVIALITY]; ALL_TAC] THEN
    POP_ASSUM MP_TAC THEN
    REWRITE_TAC[TRIVIAL_GROUP; LEFT_IMP_EXISTS_THM] THEN
    X_GEN_TAC `a:A` THEN DISCH_TAC THEN
    X_GEN_TAC `b:B` THEN DISCH_TAC THEN
    REWRITE_TAC[isomorphic_group; GROUP_ISOMORPHISM] THEN
    EXISTS_TAC `(\x. b):A->B` THEN
    ASM_REWRITE_TAC[group_homomorphism] THEN
    SIMP_TAC[IN_SING; IMAGE_CLAUSES; SUBSET_REFL] THEN
    ASM_MESON_TAC[GROUP_ID; GROUP_INV; GROUP_OP; IN_SING]) in
  REWRITE_TAC[lemma] THEN ONCE_REWRITE_TAC[ISOMORPHIC_GROUP_SYM] THEN
  REWRITE_TAC[lemma]);;

let ISOMORPHIC_GROUP_SINGLETON_GROUP = prove
 (`(!(G:A group) (b:B).
        G isomorphic_group singleton_group b <=> trivial_group G) /\
   (!a:A (G:B group).
        singleton_group a isomorphic_group G <=> trivial_group G)`,
  MESON_TAC[ISOMORPHIC_TO_TRIVIAL_GROUP; TRIVIAL_GROUP_SINGLETON_GROUP]);;

let ISOMORPHIC_GROUP_PROD_GROUPS = prove
 (`!(G:A group) (G':B group) (H:C group) (H':D group).
        G isomorphic_group G' /\ H isomorphic_group H'
        ==> (prod_group G H) isomorphic_group (prod_group G' H')`,
  REWRITE_TAC[isomorphic_group; group_isomorphism; RIGHT_AND_EXISTS_THM] THEN
  REWRITE_TAC[LEFT_AND_EXISTS_THM; LEFT_IMP_EXISTS_THM] THEN
  REWRITE_TAC[GSYM GROUP_ISOMORPHISMS_PAIRED2] THEN MESON_TAC[]);;

(* ------------------------------------------------------------------------- *)
(* Perform group operations setwise.                                         *)
(* ------------------------------------------------------------------------- *)

let group_setinv = new_definition
 `group_setinv G g = {group_inv G x | x IN g}`;;

let group_setop = new_definition
 `group_setop G g h = {group_op G x y | x IN g /\ y IN h}`;;

let SUBGROUP_OF_SETWISE = prove
 (`!G s:A->bool.
        s subgroup_of G <=>
        s SUBSET group_carrier G /\
        group_id G IN s /\
        group_setinv G s SUBSET s /\
        group_setop G s s SUBSET s`,
  REWRITE_TAC[subgroup_of; group_setinv; group_setop] THEN SET_TAC[]);;

let OPPOSITE_GROUP_SETINV = prove
 (`!G s:A->bool.
        group_setinv (opposite_group G) s = group_setinv G s`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[group_setinv; OPPOSITE_GROUP]);;

let OPPOSITE_GROUP_SETOP = prove
 (`!G s t:A->bool.
        group_setop (opposite_group G) s t = group_setop G t s`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[group_setop; OPPOSITE_GROUP] THEN
  SET_TAC[]);;

let GROUP_SETINV_EQ_EMPTY = prove
 (`!G g:A->bool. group_setinv G g = {} <=> g = {}`,
  REWRITE_TAC[group_setinv] THEN SET_TAC[]);;

let GROUP_SETOP_EQ_EMPTY = prove
 (`!G g h:A->bool. group_setop G g h = {} <=> g = {} \/ h = {}`,
  REWRITE_TAC[group_setop] THEN SET_TAC[]);;

let GROUP_SETINV_SING = prove
 (`!G x:A. group_setinv G {x} = {group_inv G x}`,
  REWRITE_TAC[group_setinv] THEN SET_TAC[]);;

let GROUP_SETOP_SING = prove
 (`!G x y:A. group_setop G {x} {y} = {group_op G x y}`,
  REWRITE_TAC[group_setop] THEN SET_TAC[]);;

let GROUP_SETINV = prove
 (`!G g:A->bool.
        g SUBSET group_carrier G ==> group_setinv G g SUBSET group_carrier G`,
  SIMP_TAC[group_setinv; SUBSET; FORALL_IN_GSPEC; GROUP_INV]);;

let GROUP_SETOP = prove
 (`!G g h:A->bool.
        g SUBSET group_carrier G /\ h SUBSET group_carrier G==>
        group_setop G g h SUBSET group_carrier G`,
  SIMP_TAC[group_setop; SUBSET; FORALL_IN_GSPEC; GROUP_OP]);;

let GROUP_SETOP_LID = prove
 (`!G g:A->bool.
        g SUBSET group_carrier G ==> group_setop G {group_id G} g = g`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[group_setop] THEN MATCH_MP_TAC(SET_RULE
   `(!y. y IN s ==> f a y = y) ==> {f x y | x IN {a} /\ y IN s} = s`) THEN
  RULE_ASSUM_TAC(REWRITE_RULE[SUBSET]) THEN ASM_SIMP_TAC[GROUP_OP_LID]);;

let GROUP_SETOP_RID = prove
 (`!G g:A->bool.
        g SUBSET group_carrier G ==> group_setop G g {group_id G} = g`,
  ONCE_REWRITE_TAC[GSYM OPPOSITE_GROUP_SETOP] THEN
  MESON_TAC[GROUP_SETOP_LID; OPPOSITE_GROUP]);;

let GROUP_SETOP_ASSOC = prove
 (`!G g h i:A->bool.
        g SUBSET group_carrier G /\ h SUBSET group_carrier G /\
        i SUBSET group_carrier G
        ==> group_setop G g (group_setop G h i) =
            group_setop G (group_setop G g h) i`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[group_setop] THEN
  REWRITE_TAC[SET_RULE
   `{f x y |x,y| x IN s /\ y IN {g w z | w IN t /\ z IN u}} =
    {f x (g y z) | x IN s /\ y IN t /\ z IN u}`] THEN
  REWRITE_TAC[SET_RULE
   `{f x y |x,y| x IN {g w z | w IN s /\ z IN t} /\ y IN u} =
    {f (g x y) z | x IN s /\ y IN t /\ z IN u}`] THEN
  MATCH_MP_TAC(SET_RULE
   `(!x y z. P x y z ==> f x y z = g x y z)
    ==> {f x y z | P x y z} = {g x y z | P x y z}`) THEN
  REPEAT STRIP_TAC THEN MATCH_MP_TAC GROUP_OP_ASSOC THEN
  ASM SET_TAC[]);;

let GROUP_SETINV_SUBGROUP = prove
 (`!G h:A->bool. h subgroup_of G ==> group_setinv G h = h`,
  REWRITE_TAC[group_setinv; subgroup_of; SUBSET] THEN REPEAT STRIP_TAC THEN
  MATCH_MP_TAC(SET_RULE
   `(!x. x IN s ==> f x IN s /\ f(f x) = x) ==> {f x | x IN s} = s`) THEN
  ASM_SIMP_TAC[GROUP_INV_INV]);;

let GROUP_SETOP_LSUBSET = prove
 (`!G h s:A->bool.
        h subgroup_of G /\ s SUBSET h /\ ~(s = {}) ==> group_setop G s h = h`,
  REWRITE_TAC[group_setop; subgroup_of; SUBSET] THEN REPEAT STRIP_TAC THEN
  ASM_SIMP_TAC[GSYM SUBSET_ANTISYM_EQ; SUBSET; GROUP_OP; FORALL_IN_GSPEC] THEN
  X_GEN_TAC `x:A` THEN DISCH_TAC THEN REWRITE_TAC[IN_ELIM_THM] THEN
  FIRST_X_ASSUM(X_CHOOSE_TAC `y:A` o REWRITE_RULE[GSYM MEMBER_NOT_EMPTY]) THEN
  MAP_EVERY EXISTS_TAC [`y:A`; `group_op G (group_inv G y) x:A`] THEN
  ASM_SIMP_TAC[] THEN
  W(MP_TAC o PART_MATCH (lhand o rand) GROUP_OP_ASSOC o rand o snd) THEN
  ASM_SIMP_TAC[GROUP_OP; GROUP_INV; GROUP_OP_RINV; GROUP_OP_LID]);;

let GROUP_SETOP_RSUBSET = prove
 (`!G h s:A->bool.
        h subgroup_of G /\ s SUBSET h /\ ~(s = {}) ==> group_setop G h s = h`,
  ONCE_REWRITE_TAC[GSYM OPPOSITE_GROUP_SETOP] THEN
  SIMP_TAC[GROUP_SETOP_LSUBSET; SUBGROUP_OF_OPPOSITE_GROUP; OPPOSITE_GROUP]);;

let GROUP_SETOP_LSUBSET_EQ = prove
 (`!G h s:A->bool.
        h subgroup_of G /\ s SUBSET group_carrier G
        ==> (group_setop G s h = h <=> s SUBSET h /\ ~(s = {}))`,
  REPEAT STRIP_TAC THEN ASM_CASES_TAC `s:A->bool = {}` THENL
   [ASM_MESON_TAC[GROUP_SETOP_EQ_EMPTY; SUBGROUP_OF_IMP_NONEMPTY];
    ASM_REWRITE_TAC[]] THEN
  EQ_TAC THENL [ALL_TAC; ASM_MESON_TAC[GROUP_SETOP_LSUBSET]] THEN
  DISCH_THEN(SUBST1_TAC o SYM) THEN
  REWRITE_TAC[group_setop; IN_ELIM_THM; SUBSET] THEN
  X_GEN_TAC `x:A` THEN DISCH_TAC THEN
  MAP_EVERY EXISTS_TAC [`x:A`; `group_id G:A`] THEN
  RULE_ASSUM_TAC(REWRITE_RULE[subgroup_of; SUBSET]) THEN
  ASM_SIMP_TAC[GROUP_OP_RID]);;

let GROUP_SETOP_RSUBSET_EQ = prove
 (`!G h s:A->bool.
        h subgroup_of G /\ s SUBSET group_carrier G
        ==> (group_setop G h s = h <=> s SUBSET h /\ ~(s = {}))`,
  ONCE_REWRITE_TAC[GSYM OPPOSITE_GROUP_SETOP] THEN
  SIMP_TAC[GROUP_SETOP_LSUBSET_EQ; SUBGROUP_OF_OPPOSITE_GROUP;
           OPPOSITE_GROUP]);;

let GROUP_SETOP_SUBGROUP = prove
 (`!G h:A->bool.
        h subgroup_of G ==> group_setop G h h = h`,
  REPEAT STRIP_TAC THEN MATCH_MP_TAC GROUP_SETOP_LSUBSET THEN
  ASM_MESON_TAC[SUBGROUP_OF_IMP_NONEMPTY; SUBSET_REFL]);;

let GROUP_SETOP_LCANCEL = prove
 (`!G g h x:A.
        x IN group_carrier G /\
        g SUBSET group_carrier G /\ h SUBSET group_carrier G
        ==> (group_setop G {x} g = group_setop G {x} h <=> g = h)`,
  REPEAT STRIP_TAC THEN EQ_TAC THEN SIMP_TAC[] THEN
  DISCH_THEN(MP_TAC o AP_TERM `group_setop G {group_inv G x:A}`) THEN
  ASM_SIMP_TAC[GROUP_SETOP_ASSOC; SING_SUBSET; GROUP_INV] THEN
  ASM_SIMP_TAC[GROUP_SETOP_SING; GROUP_OP_LINV; GROUP_SETOP_LID]);;

let GROUP_SETOP_RCANCEL = prove
 (`!G g h x:A.
        x IN group_carrier G /\ g SUBSET group_carrier G /\
        h SUBSET group_carrier G
        ==> (group_setop G g {x} = group_setop G h {x} <=> g = h)`,
  ONCE_REWRITE_TAC[GSYM OPPOSITE_GROUP_SETOP] THEN
  SIMP_TAC[GROUP_SETOP_LCANCEL; OPPOSITE_GROUP]);;

let GROUP_SETOP_LCANCEL_SET = prove
 (`!G h x y:A.
        x IN group_carrier G /\ y IN group_carrier G /\ h subgroup_of G
        ==> (group_setop G h {x} = group_setop G h {y} <=>
             group_div G x y IN h)`,
  REPEAT STRIP_TAC THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP SUBGROUP_OF_IMP_SUBSET) THEN
  TRANS_TAC EQ_TRANS
   `group_setop G (group_setop G h {x}) {group_inv G y}  =
    group_setop G (group_setop G h {y:A}) {group_inv G y}` THEN
  CONJ_TAC THENL
   [CONV_TAC SYM_CONV THEN MATCH_MP_TAC GROUP_SETOP_RCANCEL THEN
    ASM_SIMP_TAC[GROUP_INV; GROUP_SETOP; SING_SUBSET];
    ASM_SIMP_TAC[GSYM GROUP_SETOP_ASSOC; GROUP_INV; SING_SUBSET] THEN
    ASM_SIMP_TAC[GROUP_SETOP_SING; GROUP_OP_RINV; GROUP_SETOP_RID] THEN
    ASM_SIMP_TAC[GROUP_SETOP_RSUBSET_EQ; SING_SUBSET; group_div;
                 GROUP_INV; GROUP_OP; NOT_INSERT_EMPTY]]);;

let GROUP_SETOP_RCANCEL_SET = prove
 (`!G h x y:A.
        x IN group_carrier G /\ y IN group_carrier G /\ h subgroup_of G
        ==> (group_setop G {x} h = group_setop G {y} h <=>
             group_op G (group_inv G x) y IN h)`,
  REPEAT STRIP_TAC THEN GEN_REWRITE_TAC LAND_CONV [EQ_SYM_EQ] THEN
  ONCE_REWRITE_TAC[GSYM OPPOSITE_GROUP_SETOP] THEN
  ASM_SIMP_TAC[GROUP_SETOP_LCANCEL_SET; OPPOSITE_GROUP;
               SUBGROUP_OF_OPPOSITE_GROUP; group_div]);;

let SUBGROUP_SETOP_EQ = prove
 (`!G g h:A->bool.
        g subgroup_of G /\ h subgroup_of G
        ==> ((group_setop G g h) subgroup_of G <=>
             group_setop G g h = group_setop G h g)`,
  REPEAT STRIP_TAC THEN EQ_TAC THENL
   [DISCH_TAC THEN MATCH_MP_TAC SUBSET_ANTISYM THEN
    REWRITE_TAC[SUBSET; group_setop; FORALL_IN_GSPEC] THEN
    CONJ_TAC THEN MAP_EVERY X_GEN_TAC [`x:A`; `y:A`] THEN STRIP_TAC THEN
    REWRITE_TAC[IN_ELIM_THM] THEN
    FIRST_ASSUM(MP_TAC o GEN_REWRITE_RULE I [subgroup_of]) THEN
    DISCH_THEN(MP_TAC o el 2 o CONJUNCTS) THENL
     [DISCH_THEN(MP_TAC o SPEC `group_op G x y:A`) THEN
      REWRITE_TAC[group_setop; IN_ELIM_THM] THEN
      ANTS_TAC THENL [ASM_MESON_TAC[]; REWRITE_TAC[LEFT_IMP_EXISTS_THM]] THEN
      MAP_EVERY X_GEN_TAC [`w:A`; `z:A`] THEN STRIP_TAC THEN
      FIRST_X_ASSUM(MP_TAC o AP_TERM `group_inv (G:A group)`) THEN
      RULE_ASSUM_TAC(REWRITE_RULE[subgroup_of; SUBSET]) THEN
      ASM_SIMP_TAC[GROUP_INV_INV; GROUP_OP] THEN
      ASM_SIMP_TAC[GROUP_INV_OP] THEN ASM_MESON_TAC[];
      DISCH_THEN(MP_TAC o SPEC
       `group_op G (group_inv G y) (group_inv G x):A`) THEN
      RULE_ASSUM_TAC(REWRITE_RULE[subgroup_of; SUBSET]) THEN
      REWRITE_TAC[group_setop; IN_ELIM_THM] THEN
      ANTS_TAC THENL [ASM_MESON_TAC[]; REWRITE_TAC[LEFT_IMP_EXISTS_THM]] THEN
      ASM_SIMP_TAC[GROUP_INV_OP; GROUP_INV; GROUP_OP; GROUP_INV_INV] THEN
      ASM_MESON_TAC[]];
    DISCH_TAC THEN REWRITE_TAC[SUBGROUP_OF_SETWISE] THEN
    ASM_SIMP_TAC[GROUP_SETOP; SUBGROUP_OF_IMP_SUBSET] THEN
    REWRITE_TAC[CONJ_ASSOC] THEN CONJ_TAC THENL
     [REWRITE_TAC[group_setop; group_setinv; SUBSET; IMP_CONJ;
                  RIGHT_FORALL_IMP_THM; FORALL_IN_GSPEC] THEN
      RULE_ASSUM_TAC(REWRITE_RULE[subgroup_of; SUBSET]) THEN
      ASM_SIMP_TAC[GROUP_INV_OP; IN_ELIM_THM] THEN
      CONJ_TAC THENL [ASM_MESON_TAC[GROUP_OP_LID]; ALL_TAC] THEN
      X_GEN_TAC `y:A` THEN DISCH_TAC THEN X_GEN_TAC `x:A` THEN DISCH_TAC THEN
      FIRST_X_ASSUM(MP_TAC o MATCH_MP(SET_RULE
       `s = t ==> !x. x IN s ==> x IN t`)) THEN
      REWRITE_TAC[group_setop; FORALL_IN_GSPEC] THEN
      DISCH_THEN(MP_TAC o SPECL [`group_inv G x:A`; `group_inv G y:A`]) THEN
      ASM SET_TAC[];
      TRANS_TAC SUBSET_TRANS
       `group_setop G (group_setop G h g) (group_setop G g h):A->bool` THEN
      CONJ_TAC THENL [ASM_MESON_TAC[SUBSET_REFL]; ALL_TAC] THEN
      TRANS_TAC SUBSET_TRANS
       `group_setop G h (group_setop G g (group_setop G g h)):A->bool` THEN
      CONJ_TAC THENL
       [ASM_MESON_TAC[GROUP_SETOP_ASSOC; subgroup_of; GROUP_SETOP;
                      SUBSET_REFL];
        ALL_TAC] THEN
      TRANS_TAC SUBSET_TRANS
       `group_setop G h (group_setop G (group_setop G g g) h):A->bool` THEN
      CONJ_TAC THENL
       [ASM_MESON_TAC[GROUP_SETOP_ASSOC; subgroup_of; GROUP_SETOP;
                      SUBSET_REFL];
        ALL_TAC] THEN
      ASM_SIMP_TAC[GROUP_SETOP_SUBGROUP] THEN
      ASM_SIMP_TAC[GROUP_SETOP_ASSOC; SUBGROUP_OF_IMP_SUBSET] THEN
      ASM_SIMP_TAC[GROUP_SETOP_SUBGROUP; SUBSET_REFL]]]);;

let SUBGROUP_GENERATED_SETOP = prove
 (`!G g h:A->bool.
        g subgroup_of G /\ h subgroup_of G
        ==> subgroup_generated G (group_setop G g h) =
            subgroup_generated G (g UNION h)`,
  REPEAT STRIP_TAC THEN
  REWRITE_TAC[GROUPS_EQ; CONJUNCT2 SUBGROUP_GENERATED] THEN
  MATCH_MP_TAC SUBSET_ANTISYM THEN CONJ_TAC THEN
  MATCH_MP_TAC SUBGROUP_GENERATED_MINIMAL THEN
  REWRITE_TAC[SUBGROUP_SUBGROUP_GENERATED] THEN
  REWRITE_TAC[SUBSET; group_setop; FORALL_IN_GSPEC; FORALL_IN_UNION] THENL
   [REPEAT STRIP_TAC THEN MATCH_MP_TAC(MESON[SUBGROUP_GENERATED; GROUP_OP]
     `x IN group_carrier(subgroup_generated G s) /\
      y IN group_carrier(subgroup_generated G s)
      ==> group_op G x y IN group_carrier(subgroup_generated G s)`) THEN
    CONJ_TAC;
    REPEAT STRIP_TAC] THEN
  MATCH_MP_TAC SUBGROUP_GENERATED_INC THEN
  ASM_SIMP_TAC[UNION_SUBSET; IN_UNION; SUBGROUP_OF_IMP_SUBSET] THEN
  ASM_SIMP_TAC[GSYM group_setop; GROUP_SETOP; SUBGROUP_OF_IMP_SUBSET] THEN
  REWRITE_TAC[group_setop; IN_ELIM_THM] THEN
  ASM_MESON_TAC[GROUP_OP_LID; GROUP_OP_RID; subgroup_of; SUBSET]);;

(* ------------------------------------------------------------------------- *)
(* Right and left cosets.                                                    *)
(* ------------------------------------------------------------------------- *)

let right_coset = new_definition
 `right_coset G h x = group_setop G h {x}`;;

let left_coset = new_definition
 `left_coset G x h = group_setop G {x} h`;;

let RIGHT_COSET = prove
 (`!G h x:A.
        x IN group_carrier G /\ h SUBSET group_carrier G
        ==> right_coset G h x SUBSET group_carrier G`,
  SIMP_TAC[right_coset; GROUP_SETOP; SING_SUBSET]);;

let LEFT_COSET = prove
 (`!G h x:A.
        x IN group_carrier G /\ h SUBSET group_carrier G
        ==> left_coset G x h SUBSET group_carrier G`,
  SIMP_TAC[left_coset; GROUP_SETOP; SING_SUBSET]);;

let RIGHT_COSET_OPPOSITE_GROUP = prove
 (`!G h x:A. right_coset G h x = left_coset (opposite_group G) x h`,
  REWRITE_TAC[left_coset; right_coset; OPPOSITE_GROUP_SETOP]);;

let LEFT_COSET_OPPOSITE_GROUP = prove
 (`!G h x:A. left_coset G x h = right_coset (opposite_group G) h x`,
  REWRITE_TAC[left_coset; right_coset; OPPOSITE_GROUP_SETOP]);;

let RIGHT_COSET_ID = prove
 (`!G h:A->bool.
        h SUBSET group_carrier G ==> right_coset G h (group_id G) = h`,
  SIMP_TAC[right_coset; group_setop; SET_RULE
   `{f x y | P x /\ y IN {a}} = {f x a | P x}`] THEN
  REWRITE_TAC[SUBSET] THEN REPEAT STRIP_TAC THEN MATCH_MP_TAC(SET_RULE
   `(!x. x IN s ==> f x = x) ==> {f x | x IN s} = s`) THEN
  ASM_SIMP_TAC[GROUP_OP_RID]);;

let LEFT_COSET_ID = prove
 (`!G h:A->bool.
        h SUBSET group_carrier G ==> left_coset G (group_id G) h = h`,
  MESON_TAC[RIGHT_COSET_ID; LEFT_COSET_OPPOSITE_GROUP; OPPOSITE_GROUP]);;

let LEFT_COSET_TRIVIAL = prove
 (`!G x:A. x IN group_carrier G ==> left_coset G x {group_id G} = {x}`,
  SIMP_TAC[left_coset; GROUP_SETOP_SING; GROUP_ID; GROUP_OP_RID]);;

let RIGHT_COSET_TRIVIAL = prove
 (`!G x:A. x IN group_carrier G ==> right_coset G {group_id G} x = {x}`,
  SIMP_TAC[right_coset; GROUP_SETOP_SING; GROUP_ID; GROUP_OP_LID]);;

let LEFT_COSET_CARRIER = prove
 (`!G x:A. x IN group_carrier G
           ==> left_coset G x (group_carrier G) = group_carrier G`,
  SIMP_TAC[left_coset; GROUP_SETOP_LSUBSET; SING_SUBSET; NOT_INSERT_EMPTY;
           CARRIER_SUBGROUP_OF]);;

let RIGHT_COSET_CARRIER = prove
 (`!G x:A. x IN group_carrier G
           ==> right_coset G (group_carrier G) x = group_carrier G`,
  SIMP_TAC[right_coset; GROUP_SETOP_RSUBSET; SING_SUBSET; NOT_INSERT_EMPTY;
           CARRIER_SUBGROUP_OF]);;

let RIGHT_COSET_EQ = prove
 (`!G h x y:A.
        h subgroup_of G /\ x IN group_carrier G /\ y IN group_carrier G
        ==> (right_coset G h x = right_coset G h y <=> group_div G x y IN h)`,
  SIMP_TAC[GROUP_SETOP_LCANCEL_SET; right_coset]);;

let LEFT_COSET_EQ = prove
 (`!G h x y:A.
        h subgroup_of G /\ x IN group_carrier G /\ y IN group_carrier G
        ==> (left_coset G x h = left_coset G y h <=>
             group_op G (group_inv G x) y IN h)`,
  SIMP_TAC[GROUP_SETOP_RCANCEL_SET; left_coset]);;

let RIGHT_COSET_EQ_SUBGROUP = prove
 (`!G h x:A.
        h subgroup_of G /\ x IN group_carrier G
        ==> (right_coset G h x = h <=> x IN h)`,
  SIMP_TAC[right_coset; GROUP_SETOP_RSUBSET_EQ; SING_SUBSET] THEN
  REWRITE_TAC[NOT_INSERT_EMPTY]);;

let LEFT_COSET_EQ_SUBGROUP = prove
 (`!G h x:A.
        h subgroup_of G /\ x IN group_carrier G
        ==> (left_coset G x h = h <=> x IN h)`,
  SIMP_TAC[left_coset; GROUP_SETOP_LSUBSET_EQ; SING_SUBSET] THEN
  REWRITE_TAC[NOT_INSERT_EMPTY]);;

let RIGHT_COSET_EQ_EMPTY = prove
 (`!G h x:A. right_coset G h x = {} <=> h = {}`,
  REWRITE_TAC[right_coset; GROUP_SETOP_EQ_EMPTY; NOT_INSERT_EMPTY]);;

let LEFT_COSET_EQ_EMPTY = prove
 (`!G h x:A. left_coset G x h = {} <=> h = {}`,
  REWRITE_TAC[left_coset; GROUP_SETOP_EQ_EMPTY; NOT_INSERT_EMPTY]);;

let RIGHT_COSET_NONEMPTY = prove
 (`!G h x:A. h subgroup_of G ==> ~(right_coset G h x = {})`,
  REWRITE_TAC[RIGHT_COSET_EQ_EMPTY; SUBGROUP_OF_IMP_NONEMPTY]);;

let LEFT_COSET_NONEMPTY = prove
 (`!G h x:A. h subgroup_of G ==> ~(left_coset G x h = {})`,
  REWRITE_TAC[LEFT_COSET_EQ_EMPTY; SUBGROUP_OF_IMP_NONEMPTY]);;

let IN_RIGHT_COSET_SELF = prove
 (`!G h x:A.
      h subgroup_of G /\ x IN group_carrier G ==> x IN right_coset G h x`,
  REWRITE_TAC[subgroup_of; right_coset; group_setop; IN_ELIM_THM; IN_SING] THEN
  MESON_TAC[GROUP_OP_LID]);;

let IN_LEFT_COSET_SELF = prove
 (`!G h x:A.
      h subgroup_of G /\ x IN group_carrier G ==> x IN left_coset G x h`,
  REWRITE_TAC[subgroup_of; left_coset; group_setop; IN_ELIM_THM; IN_SING] THEN
  MESON_TAC[GROUP_OP_RID]);;

let UNIONS_RIGHT_COSETS = prove
 (`!G h:A->bool.
        h subgroup_of G
        ==> UNIONS {right_coset G h x |x| x IN group_carrier G} =
            group_carrier G`,
  REPEAT STRIP_TAC THEN
  REWRITE_TAC[GSYM SUBSET_ANTISYM_EQ; UNIONS_SUBSET; FORALL_IN_GSPEC] THEN
  ASM_SIMP_TAC[RIGHT_COSET; SUBGROUP_OF_IMP_SUBSET] THEN
  REWRITE_TAC[UNIONS_GSPEC; IN_ELIM_THM; SUBSET] THEN
  ASM_MESON_TAC[IN_RIGHT_COSET_SELF]);;

let UNIONS_LEFT_COSETS = prove
 (`!G h:A->bool.
        h subgroup_of G
        ==> UNIONS {left_coset G x h |x| x IN group_carrier G} =
            group_carrier G`,
  REPEAT STRIP_TAC THEN
  REWRITE_TAC[GSYM SUBSET_ANTISYM_EQ; UNIONS_SUBSET; FORALL_IN_GSPEC] THEN
  ASM_SIMP_TAC[LEFT_COSET; SUBGROUP_OF_IMP_SUBSET] THEN
  REWRITE_TAC[UNIONS_GSPEC; IN_ELIM_THM; SUBSET] THEN
  ASM_MESON_TAC[IN_LEFT_COSET_SELF]);;

let RIGHT_COSETS_EQ = prove
 (`!G h x y:A.
        h subgroup_of G /\ x IN group_carrier G /\ y IN group_carrier G
        ==> (right_coset G h x = right_coset G h y <=>
             ~(DISJOINT (right_coset G h x) (right_coset G h y)))`,
  REPEAT STRIP_TAC THEN EQ_TAC THEN
  ASM_SIMP_TAC[GSYM DISJOINT_EMPTY_REFL; RIGHT_COSET_NONEMPTY] THEN
  ASM_SIMP_TAC[RIGHT_COSET_EQ; LEFT_IMP_EXISTS_THM; IMP_CONJ; SET_RULE
   `~DISJOINT s t <=> ?x. x IN s /\ ?y. y IN t /\ x = y`] THEN
  REWRITE_TAC[right_coset; group_setop; FORALL_IN_GSPEC; IN_SING] THEN
  REWRITE_TAC[IMP_CONJ; RIGHT_FORALL_IMP_THM; FORALL_UNWIND_THM2] THEN
  X_GEN_TAC `u:A` THEN DISCH_TAC THEN X_GEN_TAC `v:A` THEN DISCH_TAC THEN
  DISCH_THEN(MP_TAC o AP_TERM `group_op G (group_inv G u):A->A`) THEN
  RULE_ASSUM_TAC(REWRITE_RULE[subgroup_of; SUBSET]) THEN
  ASM_SIMP_TAC[GROUP_OP_ASSOC; GROUP_INV; GROUP_OP_LINV; GROUP_OP_LID] THEN
  DISCH_THEN SUBST1_TAC THEN
  ASM_SIMP_TAC[group_div; GSYM GROUP_OP_ASSOC; GROUP_INV; GROUP_OP;
               GROUP_OP_RINV; GROUP_OP_RID]);;

let LEFT_COSETS_EQ = prove
 (`!G h x y:A.
        h subgroup_of G /\ x IN group_carrier G /\ y IN group_carrier G
        ==> (left_coset G x h = left_coset G y h <=>
             ~(DISJOINT (left_coset G x h) (left_coset G y h)))`,
  REWRITE_TAC[LEFT_COSET_OPPOSITE_GROUP] THEN
  SIMP_TAC[RIGHT_COSETS_EQ; SUBGROUP_OF_OPPOSITE_GROUP; OPPOSITE_GROUP]);;

let DISJOINT_RIGHT_COSETS = prove
 (`!G h x y:A.
        h subgroup_of G /\ x IN group_carrier G /\ y IN group_carrier G
        ==> (DISJOINT (right_coset G h x) (right_coset G h y) <=>
             ~(right_coset G h x = right_coset G h y))`,
  SIMP_TAC[RIGHT_COSETS_EQ]);;

let DISJOINT_LEFT_COSETS = prove
 (`!G h x y:A.
        h subgroup_of G /\ x IN group_carrier G /\ y IN group_carrier G
        ==> (DISJOINT (left_coset G x h) (left_coset G y h) <=>
             ~(left_coset G x h = left_coset G y h))`,
  SIMP_TAC[LEFT_COSETS_EQ]);;

let IMAGE_RIGHT_COSET_SWITCH = prove
 (`!G h x y:A.
        h subgroup_of G /\ x IN group_carrier G /\ y IN group_carrier G
        ==> IMAGE (\a. group_op G a (group_op G (group_inv G x) y))
                  (right_coset G h x) =
            right_coset G h y`,
  REPEAT STRIP_TAC THEN TRANS_TAC EQ_TRANS
   `group_setop G (right_coset G h x) {group_op G (group_inv G x) y:A}` THEN
  CONJ_TAC THENL [REWRITE_TAC[group_setop] THEN SET_TAC[]; ALL_TAC] THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP SUBGROUP_OF_IMP_SUBSET) THEN
  REWRITE_TAC[right_coset] THEN
  ASM_SIMP_TAC[GSYM GROUP_SETOP_ASSOC; GROUP_SETOP; SING_SUBSET;
               GROUP_OP; GROUP_INV; GROUP_SETOP_SING; GROUP_OP_ASSOC;
               GROUP_OP_RINV; GROUP_OP_LID]);;

let IMAGE_LEFT_COSET_SWITCH = prove
 (`!G h x y:A.
        h subgroup_of G /\ x IN group_carrier G /\ y IN group_carrier G
        ==> IMAGE (\a. group_op G (group_div G y x) a)
                  (left_coset G x h) =
            left_coset G y h`,
  REPEAT STRIP_TAC THEN TRANS_TAC EQ_TRANS
   `group_setop G {group_div G y x:A} (left_coset G x h)` THEN
  CONJ_TAC THENL [REWRITE_TAC[group_setop] THEN SET_TAC[]; ALL_TAC] THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP SUBGROUP_OF_IMP_SUBSET) THEN
  REWRITE_TAC[left_coset; group_div] THEN
  ASM_SIMP_TAC[GROUP_SETOP_ASSOC; GROUP_SETOP; SING_SUBSET;
               GROUP_OP; GROUP_INV; GROUP_SETOP_SING; GSYM GROUP_OP_ASSOC;
               GROUP_OP_LINV; GROUP_OP_RID]);;

let CARD_EQ_RIGHT_COSETS = prove
 (`!G h x y:A.
        h subgroup_of G /\ x IN group_carrier G /\ y IN group_carrier G
        ==> right_coset G h x =_c right_coset G h y`,
  let lemma = prove
   (`!f g. (IMAGE f s = t /\ IMAGE g t = s) /\
           (!x y. x IN s /\ y IN s /\ f x = f y ==> x = y)
     ==> s =_c t`,
    REWRITE_TAC[eq_c; LEFT_FORALL_IMP_THM] THEN
    MATCH_MP_TAC MONO_EXISTS THEN SET_TAC[]) in
  REPEAT STRIP_TAC THEN MATCH_MP_TAC lemma THEN
  EXISTS_TAC `\a:A. group_op G a (group_op G (group_inv G x) y)` THEN
  EXISTS_TAC `\a:A. group_op G a (group_op G (group_inv G y) x)` THEN
  ASM_SIMP_TAC[IMAGE_RIGHT_COSET_SWITCH; INJECTIVE_ON_ALT] THEN
  REPEAT STRIP_TAC THEN MATCH_MP_TAC GROUP_OP_RCANCEL THEN
  ASM_MESON_TAC[GROUP_OP; GROUP_INV; SUBSET; RIGHT_COSET;
                SUBGROUP_OF_IMP_SUBSET]);;

let CARD_EQ_LEFT_COSETS = prove
 (`!G h x y:A.
        h subgroup_of G /\ x IN group_carrier G /\ y IN group_carrier G
        ==> left_coset G x h =_c left_coset G y h`,
  SIMP_TAC[LEFT_COSET_OPPOSITE_GROUP; SUBGROUP_OF_OPPOSITE_GROUP;
           OPPOSITE_GROUP; CARD_EQ_RIGHT_COSETS]);;

let CARD_EQ_RIGHT_COSET_SUBGROUP = prove
 (`!G h x y:A.
        h subgroup_of G /\ x IN group_carrier G /\ y IN group_carrier G
        ==> right_coset G h x =_c h`,
  MESON_TAC[CARD_EQ_RIGHT_COSETS; GROUP_ID; RIGHT_COSET_ID;
            SUBGROUP_OF_IMP_SUBSET]);;

let CARD_EQ_LEFT_COSET_SUBGROUP = prove
 (`!G h x y:A.
        h subgroup_of G /\ x IN group_carrier G /\ y IN group_carrier G
        ==> left_coset G x h =_c h`,
  MESON_TAC[CARD_EQ_LEFT_COSETS; GROUP_ID; LEFT_COSET_ID;
            SUBGROUP_OF_IMP_SUBSET]);;

let LAGRANGE_THEOREM_RIGHT = prove
 (`!G h:A->bool.
        FINITE(group_carrier G) /\ h subgroup_of G
        ==> CARD {right_coset G h x |x| x IN group_carrier G} * CARD h =
            CARD(group_carrier G)`,
  REPEAT STRIP_TAC THEN
  SUBGOAL_THEN `FINITE(h:A->bool)` STRIP_ASSUME_TAC THENL
   [ASM_MESON_TAC[FINITE_SUBSET; subgroup_of]; ALL_TAC] THEN
  FIRST_ASSUM(fun th -> GEN_REWRITE_TAC (RAND_CONV o RAND_CONV)
   [SYM(MATCH_MP UNIONS_RIGHT_COSETS th)]) THEN
  W(MP_TAC o PART_MATCH (lhand o rand) CARD_UNIONS o rand o snd) THEN
  ASM_REWRITE_TAC[SIMPLE_IMAGE; IMP_CONJ; RIGHT_FORALL_IMP_THM] THEN
  ASM_SIMP_TAC[FORALL_IN_IMAGE; FINITE_IMAGE] THEN
  ASM_SIMP_TAC[GSYM DISJOINT; DISJOINT_RIGHT_COSETS] THEN
  REWRITE_TAC[right_coset; group_setop; SET_RULE
   `{f x y | x IN s /\ y IN {a}} = IMAGE (\x. f x a) s`] THEN
  ASM_SIMP_TAC[FINITE_IMAGE] THEN DISCH_THEN SUBST1_TAC THEN
  ASM_SIMP_TAC[GSYM NSUM_CONST; FINITE_IMAGE] THEN
  MATCH_MP_TAC NSUM_EQ THEN REWRITE_TAC[FORALL_IN_IMAGE] THEN
  REPEAT STRIP_TAC THEN CONV_TAC SYM_CONV THEN
  MATCH_MP_TAC CARD_IMAGE_INJ THEN
  RULE_ASSUM_TAC(REWRITE_RULE[subgroup_of; SUBSET]) THEN
  ASM_SIMP_TAC[IMP_CONJ; GROUP_OP_RCANCEL]);;

let LAGRANGE_THEOREM_LEFT = prove
 (`!G h:A->bool.
        FINITE(group_carrier G) /\ h subgroup_of G
        ==> CARD {left_coset G x h |x| x IN group_carrier G} * CARD h =
            CARD(group_carrier G)`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[LEFT_COSET_OPPOSITE_GROUP] THEN
  ONCE_REWRITE_TAC[SYM(CONJUNCT1(SPEC_ALL OPPOSITE_GROUP))] THEN
  MATCH_MP_TAC LAGRANGE_THEOREM_RIGHT THEN
  ASM_REWRITE_TAC[SUBGROUP_OF_OPPOSITE_GROUP; OPPOSITE_GROUP]);;

let LAGRANGE_THEOREM = prove
 (`!G h:A->bool.
        FINITE(group_carrier G) /\ h subgroup_of G
        ==> (CARD h) divides CARD(group_carrier G)`,
  REPEAT GEN_TAC THEN
  DISCH_THEN(SUBST1_TAC o SYM o MATCH_MP LAGRANGE_THEOREM_RIGHT) THEN
  NUMBER_TAC);;

(* ------------------------------------------------------------------------- *)
(* Normal subgroups.                                                         *)
(* ------------------------------------------------------------------------- *)

parse_as_infix ("normal_subgroup_of",(12,"right"));;

let normal_subgroup_of = new_definition
  `(n:A->bool) normal_subgroup_of (G:A group) <=>
        n subgroup_of G /\
        !x. x IN group_carrier G ==> left_coset G x n = right_coset G n x`;;

let NORMAL_SUBGROUP_IMP_SUBGROUP = prove
 (`!G n:A->bool. n normal_subgroup_of G ==> n subgroup_of G`,
  SIMP_TAC[normal_subgroup_of]);;

let NORMAL_SUBGROUP_OF_OPPOSITE_GROUP = prove
 (`!G n:A->bool.
        n normal_subgroup_of opposite_group G <=> n normal_subgroup_of G`,
  REWRITE_TAC[normal_subgroup_of; SUBGROUP_OF_OPPOSITE_GROUP] THEN
  REWRITE_TAC[GSYM LEFT_COSET_OPPOSITE_GROUP; OPPOSITE_GROUP;
              GSYM RIGHT_COSET_OPPOSITE_GROUP] THEN
  MESON_TAC[]);;

let NORMAL_SUBGROUP_CONJUGATE_ALT = prove
 (`!G n:A->bool.
        n normal_subgroup_of G <=>
        n subgroup_of G /\
        !x. x IN group_carrier G
            ==> group_setop G {group_inv G x} (group_setop G n {x}) = n`,
  REPEAT GEN_TAC THEN REWRITE_TAC[normal_subgroup_of] THEN
  ASM_CASES_TAC `(n:A->bool) subgroup_of G` THEN ASM_REWRITE_TAC[] THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP SUBGROUP_OF_IMP_SUBSET) THEN
  EQ_TAC THEN DISCH_TAC THEN X_GEN_TAC `x:A` THEN DISCH_TAC THEN
  FIRST_X_ASSUM(MP_TAC o SPEC `x:A`) THEN
  ASM_REWRITE_TAC[left_coset; right_coset] THENL
   [DISCH_THEN(SUBST1_TAC o SYM) THEN
    ASM_SIMP_TAC[GROUP_SETOP_ASSOC; SING_SUBSET; GROUP_INV] THEN
    ASM_SIMP_TAC[GROUP_SETOP_SING; GROUP_OP_LINV; GROUP_SETOP_LID];
    DISCH_THEN(MP_TAC o AP_TERM `group_setop G {x:A}`) THEN
    ASM_SIMP_TAC[GROUP_SETOP_ASSOC; GROUP_INV; GROUP_SETOP; SING_SUBSET] THEN
    ASM_SIMP_TAC[GROUP_SETOP_SING; GROUP_OP_RINV; GROUP_SETOP_LID]]);;

let NORMAL_SUBGROUP_CONJUGATE = prove
 (`!G n:A->bool.
      n normal_subgroup_of G <=>
      n subgroup_of G /\
      !x. x IN group_carrier G
          ==> group_setop G {group_inv G x} (group_setop G n {x}) SUBSET n`,
  REPEAT GEN_TAC THEN REWRITE_TAC[NORMAL_SUBGROUP_CONJUGATE_ALT] THEN
  ASM_CASES_TAC `(n:A->bool) subgroup_of G` THEN ASM_REWRITE_TAC[] THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP SUBGROUP_OF_IMP_SUBSET) THEN
  EQ_TAC THEN SIMP_TAC[GSYM SUBSET_ANTISYM_EQ] THEN
  DISCH_TAC THEN X_GEN_TAC `x:A` THEN DISCH_TAC THEN
  FIRST_X_ASSUM(MP_TAC o SPEC `group_inv G (x:A)`) THEN
  ASM_SIMP_TAC[GROUP_INV; GROUP_INV_INV] THEN DISCH_THEN(MP_TAC o
   ISPEC `\y:A. group_op G (group_inv G x) (group_op G y x)` o
   MATCH_MP IMAGE_SUBSET) THEN
  REWRITE_TAC[group_setop; SIMPLE_IMAGE;
    SET_RULE `{f x y | x IN {a} /\ P y} = {f a y | P y}`;
    SET_RULE `{f x y | P x /\ y IN {a}} = {f x a | P x}`] THEN
  REWRITE_TAC[GSYM IMAGE_o; o_DEF] THEN MATCH_MP_TAC(SET_RULE
   `(!x. x IN s ==> f x = x) ==> IMAGE f s SUBSET t ==> s SUBSET t`) THEN
  RULE_ASSUM_TAC(REWRITE_RULE[SUBSET]) THEN
  ASM (CONV_TAC o GEN_SIMPLIFY_CONV TOP_DEPTH_SQCONV (basic_ss []) 4)
   [GROUP_OP_ASSOC; GROUP_OP; GROUP_INV; GROUP_OP_LINV] THEN
  ASM_SIMP_TAC[GSYM GROUP_OP_ASSOC; GROUP_OP_LINV; GROUP_OP; GROUP_INV] THEN
  ASM_SIMP_TAC[GROUP_OP_LID] THEN
  ASM_SIMP_TAC[GSYM GROUP_OP_ASSOC; GROUP_OP_LINV; GROUP_OP; GROUP_INV] THEN
  ASM_SIMP_TAC[GROUP_OP_RID]);;

let TRIVIAL_NORMAL_SUBGROUP_OF = prove
 (`!G:A group. {group_id G} normal_subgroup_of G`,
  SIMP_TAC[normal_subgroup_of; TRIVIAL_SUBGROUP_OF;
           RIGHT_COSET_TRIVIAL; LEFT_COSET_TRIVIAL]);;

let CARRIER_NORMAL_SUBGROUP_OF = prove
 (`!G:A group. (group_carrier G) normal_subgroup_of G`,
  SIMP_TAC[normal_subgroup_of; CARRIER_SUBGROUP_OF] THEN
  SIMP_TAC[LEFT_COSET_CARRIER; RIGHT_COSET_CARRIER]);;

let GROUP_SETINV_RIGHT_COSET = prove
 (`!G n a:A.
        n normal_subgroup_of G /\ a IN group_carrier G
        ==> group_setinv G (right_coset G n a) =
            right_coset G n (group_inv G a)`,
  REWRITE_TAC[normal_subgroup_of; left_coset; right_coset] THEN
  REPEAT STRIP_TAC THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP SUBGROUP_OF_IMP_SUBSET) THEN
  TRANS_TAC EQ_TRANS
    `group_setop G {group_inv G a} (group_setinv G n):A->bool` THEN
  CONJ_TAC THENL
   [REWRITE_TAC[group_setinv; group_setop;
      SET_RULE `{f x y | P x /\ y IN {a}} = {f x a | P x}`;
      SET_RULE `{f x y | x IN {a} /\ P y} = {f a y | P y}`] THEN
    REWRITE_TAC[SIMPLE_IMAGE; GSYM IMAGE_o] THEN MATCH_MP_TAC(SET_RULE
     `(!x. x IN s ==> f x = g x) ==> IMAGE f s = IMAGE g s`) THEN
    RULE_ASSUM_TAC(REWRITE_RULE[SUBSET]) THEN
    ASM_SIMP_TAC[GROUP_INV_OP; o_DEF];
    ASM_SIMP_TAC[GROUP_SETINV_SUBGROUP; GROUP_INV]]);;

let GROUP_SETINV_LEFT_COSET = prove
 (`!G n a:A.
        n normal_subgroup_of G /\ a IN group_carrier G
        ==> group_setinv G (left_coset G a n) =
            left_coset G (group_inv G a) n`,
  REWRITE_TAC[LEFT_COSET_OPPOSITE_GROUP] THEN
  ONCE_REWRITE_TAC[GSYM OPPOSITE_GROUP_SETINV] THEN
  SIMP_TAC[GROUP_SETINV_RIGHT_COSET; NORMAL_SUBGROUP_OF_OPPOSITE_GROUP;
           OPPOSITE_GROUP]);;

let GROUP_SETOP_RIGHT_COSET = prove
 (`!G n a b:A.
        n normal_subgroup_of G /\ a IN group_carrier G /\ b IN group_carrier G
        ==> group_setop G (right_coset G n a) (right_coset G n b) =
            right_coset G n (group_op G a b)`,
  REWRITE_TAC[normal_subgroup_of; left_coset; right_coset] THEN
  REPEAT STRIP_TAC THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP SUBGROUP_OF_IMP_SUBSET) THEN
  FIRST_ASSUM(MP_TAC o SPEC `a:A`) THEN
  ANTS_TAC THENL [ASM_REWRITE_TAC[]; DISCH_THEN(SUBST1_TAC o SYM)] THEN
  ASM_SIMP_TAC[SING_SUBSET;
    MESON[GROUP_SETOP_ASSOC; GROUP_SETOP; GROUP_SETINV]
   `a SUBSET group_carrier G /\ b SUBSET group_carrier G /\
    c SUBSET group_carrier G /\ d SUBSET group_carrier G
    ==> group_setop G (group_setop G a b) (group_setop G c d) =
        group_setop G a (group_setop G (group_setop G b c) d)`] THEN
  ASM_SIMP_TAC[GROUP_SETOP_SUBGROUP] THEN
  FIRST_ASSUM(MP_TAC o SPEC `b:A`) THEN
  ANTS_TAC THENL [ASM_REWRITE_TAC[]; DISCH_THEN(SUBST1_TAC o SYM)] THEN
  FIRST_X_ASSUM(MP_TAC o SPEC `group_op G a b:A`) THEN
  ASM_SIMP_TAC[GROUP_OP] THEN DISCH_THEN(SUBST1_TAC o SYM) THEN
  ASM_SIMP_TAC[GROUP_SETOP_ASSOC; SING_SUBSET; GROUP_SETOP_SING]);;

let GROUP_SETOP_LEFT_COSET = prove
 (`!G n a b:A.
        n normal_subgroup_of G /\ a IN group_carrier G /\ b IN group_carrier G
        ==> group_setop G (left_coset G a n) (left_coset G b n) =
            left_coset G (group_op G a b) n`,
  REWRITE_TAC[LEFT_COSET_OPPOSITE_GROUP] THEN
  ONCE_REWRITE_TAC[GSYM OPPOSITE_GROUP_SETOP] THEN
  SIMP_TAC[GROUP_SETOP_RIGHT_COSET; NORMAL_SUBGROUP_OF_OPPOSITE_GROUP;
           OPPOSITE_GROUP]);;

(* ------------------------------------------------------------------------- *)
(* Quotient groups.                                                          *)
(* ------------------------------------------------------------------------- *)

let quotient_group = new_definition
 `quotient_group G (n:A->bool) =
        group ({right_coset G n x |x| x IN group_carrier G},
               n,group_setinv G,group_setop G)`;;

let QUOTIENT_GROUP = prove
 (`(!G n:A->bool.
        n normal_subgroup_of G
        ==> group_carrier(quotient_group G n) =
              {right_coset G n x |x| x IN group_carrier G}) /\
   (!G n:A->bool.
        n normal_subgroup_of G
        ==> group_id(quotient_group G n) = n) /\
   (!G n:A->bool.
        n normal_subgroup_of G
        ==> group_inv(quotient_group G n) = group_setinv G) /\
   (!G n:A->bool.
        n normal_subgroup_of G
        ==> group_op(quotient_group G n) = group_setop G)`,
  REWRITE_TAC[AND_FORALL_THM; TAUT
   `(p ==> q) /\ (p ==> r) <=> p ==> q /\ r`] THEN
  REPEAT GEN_TAC THEN DISCH_TAC THEN
  MP_TAC(fst(EQ_IMP_RULE
   (ISPEC(rand(rand(snd(strip_forall(concl quotient_group)))))
   (CONJUNCT2 group_tybij)))) THEN
  REWRITE_TAC[GSYM quotient_group] THEN ANTS_TAC THENL
   [ALL_TAC; SIMP_TAC[group_carrier; group_id; group_inv; group_op]] THEN
  REWRITE_TAC[RIGHT_FORALL_IMP_THM; IMP_CONJ; FORALL_IN_GSPEC] THEN
  ASM_SIMP_TAC[GROUP_SETOP_RIGHT_COSET; GROUP_SETINV_RIGHT_COSET;
               GROUP_OP; GROUP_INV] THEN
  FIRST_ASSUM(STRIP_ASSUME_TAC o REWRITE_RULE[normal_subgroup_of]) THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP SUBGROUP_OF_IMP_SUBSET) THEN
  REWRITE_TAC[IN_ELIM_THM] THEN REPEAT CONJ_TAC THENL
   [ASM_MESON_TAC[RIGHT_COSET_ID; GROUP_ID];
    ASM_MESON_TAC[GROUP_INV];
    ASM_MESON_TAC[GROUP_OP];
    ASM_SIMP_TAC[GROUP_OP_ASSOC];
    X_GEN_TAC `x:A` THEN DISCH_TAC THEN CONJ_TAC THENL
     [ASM_SIMP_TAC[right_coset; GROUP_SETOP_ASSOC; SING_SUBSET];
      FIRST_X_ASSUM(MP_TAC o SPEC `x:A`) THEN
      ASM_REWRITE_TAC[] THEN DISCH_THEN(SUBST1_TAC o SYM) THEN
      ASM_SIMP_TAC[left_coset; GSYM GROUP_SETOP_ASSOC; SING_SUBSET]] THEN
    ASM_SIMP_TAC[GROUP_SETOP_SUBGROUP];
    ASM_SIMP_TAC[GROUP_OP_LINV; GROUP_OP_RINV; RIGHT_COSET_ID]]);;

let QUOTIENT_GROUP_ID = prove
 (`!G n:A->bool.
        n normal_subgroup_of G
        ==> group_id(quotient_group G n) = n`,
  REWRITE_TAC[QUOTIENT_GROUP]);;

let QUOTIENT_GROUP_INV = prove
 (`!G n a:A.
        n normal_subgroup_of G /\ a IN group_carrier G
        ==> group_inv (quotient_group G n) (right_coset G n a) =
            right_coset G n (group_inv G a)`,
  SIMP_TAC[QUOTIENT_GROUP; GROUP_SETINV_RIGHT_COSET]);;

let QUOTIENT_GROUP_OP = prove
 (`!G n a b:A.
        n normal_subgroup_of G /\ a IN group_carrier G /\ b IN group_carrier G
        ==> group_op (quotient_group G n)
                      (right_coset G n a) (right_coset G n b) =
            right_coset G n (group_op G a b)`,
  SIMP_TAC[QUOTIENT_GROUP; GROUP_SETOP_RIGHT_COSET]);;

let GROUP_HOMOMORPHISM_RIGHT_COSET = prove
 (`!G n:A->bool.
        n normal_subgroup_of G
        ==> group_homomorphism (G,quotient_group G n) (right_coset G n)`,
  SIMP_TAC[group_homomorphism; QUOTIENT_GROUP_INV; QUOTIENT_GROUP_OP] THEN
  SIMP_TAC[SUBSET; FORALL_IN_IMAGE; QUOTIENT_GROUP] THEN
  SIMP_TAC[normal_subgroup_of; subgroup_of; RIGHT_COSET_ID] THEN SET_TAC[]);;

let GROUP_EPIMORPHISM_RIGHT_COSET = prove
 (`!G n:A->bool.
        n normal_subgroup_of G
        ==> group_epimorphism (G,quotient_group G n) (right_coset G n)`,
  SIMP_TAC[group_epimorphism; GROUP_HOMOMORPHISM_RIGHT_COSET] THEN
  SIMP_TAC[QUOTIENT_GROUP] THEN SET_TAC[]);;

let TRIVIAL_QUOTIENT_GROUP_SELF = prove
 (`!G:A group. trivial_group(quotient_group G (group_carrier G))`,
  SIMP_TAC[trivial_group; QUOTIENT_GROUP; CARRIER_NORMAL_SUBGROUP_OF] THEN
  GEN_TAC THEN MATCH_MP_TAC(SET_RULE
   `~(s = {}) /\ (!x. x IN s ==> f x = a) ==> {f x | x IN s} = {a}`) THEN
  REWRITE_TAC[RIGHT_COSET_CARRIER; GROUP_CARRIER_NONEMPTY]);;

let QUOTIENT_GROUP_TRIVIAL = prove
 (`!G:A group. quotient_group G {group_id G} isomorphic_group G`,
  GEN_TAC THEN ONCE_REWRITE_TAC[ISOMORPHIC_GROUP_SYM] THEN
  REWRITE_TAC[isomorphic_group] THEN
  EXISTS_TAC `right_coset G {group_id G:A}` THEN
  SIMP_TAC[GSYM GROUP_MONOMORPHISM_EPIMORPHISM; group_monomorphism;
           GROUP_EPIMORPHISM_RIGHT_COSET; GROUP_HOMOMORPHISM_RIGHT_COSET;
           TRIVIAL_SUBGROUP_OF; TRIVIAL_NORMAL_SUBGROUP_OF;
           RIGHT_COSET_EQ; IMP_CONJ; IN_SING; GROUP_DIV_EQ_ID]);;

(* ------------------------------------------------------------------------- *)
(* Kernels and images of homomorphisms.                                      *)
(* ------------------------------------------------------------------------- *)

let group_kernel = new_definition
 `group_kernel (G,G') (f:A->B) =
    {x | x IN group_carrier G /\ f x = group_id G'}`;;

let group_image = new_definition
 `group_image (G:A group,G':B group) (f:A->B) = IMAGE f (group_carrier G)`;;

let GROUP_KERNEL_ID = prove
 (`!G G' (f:A->B).
        group_homomorphism(G,G') f
        ==> group_id G IN group_kernel (G,G') f`,
  SIMP_TAC[group_homomorphism; group_kernel; IN_ELIM_THM; GROUP_ID]);;

let GROUP_MONOMORPHISM = prove
 (`!G G' (f:A->B).
        group_monomorphism(G,G') f <=>
        group_homomorphism(G,G') f /\
        group_kernel (G,G') f = {group_id G}`,
  REPEAT GEN_TAC THEN REWRITE_TAC[group_monomorphism] THEN
  REWRITE_TAC[TAUT `(p /\ q <=> p /\ r) <=> p ==> (q <=> r)`] THEN
  REWRITE_TAC[group_homomorphism; SUBSET; FORALL_IN_IMAGE] THEN
  REPEAT STRIP_TAC THEN REWRITE_TAC[GSYM SUBSET_ANTISYM_EQ; SING_SUBSET] THEN
  ASM_REWRITE_TAC[SUBSET; IN_SING; group_kernel; IN_ELIM_THM; GROUP_ID] THEN
  EQ_TAC THEN DISCH_TAC THENL
   [X_GEN_TAC `x:A` THEN STRIP_TAC THEN
    FIRST_X_ASSUM(MP_TAC o SPECL [`x:A`; `group_id G:A`]) THEN
    ASM_SIMP_TAC[GROUP_ID];
    MAP_EVERY X_GEN_TAC [`x:A`; `y:A`] THEN STRIP_TAC THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `group_div G x y:A`) THEN
    ASM_SIMP_TAC[group_div; GROUP_OP; GROUP_INV] THEN
    REWRITE_TAC[GSYM group_div] THEN
    W(MP_TAC o PART_MATCH (lhand o rand) GROUP_DIV_EQ_ID o
      rand o lhand o snd) THEN
    ASM_REWRITE_TAC[] THEN DISCH_THEN SUBST1_TAC THEN
    DISCH_THEN MATCH_MP_TAC THEN
    W(MP_TAC o PART_MATCH (lhand o rand) GROUP_DIV_EQ_ID o snd) THEN
    ASM_SIMP_TAC[]]);;

let GROUP_MONOMORPHISM_ALT = prove
 (`!G G' (f:A->B).
        group_monomorphism(G,G') f <=>
        group_homomorphism(G,G') f /\
        !x. x IN group_carrier G /\ f x = group_id G' ==> x = group_id G`,
  REPEAT GEN_TAC THEN REWRITE_TAC[GROUP_MONOMORPHISM; group_kernel] THEN
  MP_TAC(ISPEC `G:A group` GROUP_ID) THEN
  REWRITE_TAC[group_homomorphism] THEN SET_TAC[]);;

let GROUP_EPIMORPHISM = prove
 (`!G G' (f:A->B).
        group_epimorphism(G,G') f <=>
        group_homomorphism(G,G') f /\
        group_image (G,G') f = group_carrier G'`,
  REWRITE_TAC[group_epimorphism; group_image] THEN MESON_TAC[]);;

let GROUP_EPIMORPHISM_ALT = prove
 (`!G G' (f:A->B).
        group_epimorphism(G,G') f <=>
        group_homomorphism(G,G') f /\
        group_carrier G' SUBSET group_image (G,G') f`,
  REWRITE_TAC[GROUP_EPIMORPHISM; group_homomorphism; group_image] THEN
  MESON_TAC[SUBSET_ANTISYM_EQ]);;

let GROUP_ISOMORPHISM_GROUP_KERNEL_GROUP_IMAGE = prove
 (`!G G' (f:A->B).
        group_isomorphism (G,G') f <=>
        group_homomorphism(G,G') f /\
        group_kernel (G,G') f = {group_id G} /\
        group_image (G,G') f = group_carrier G'`,
  REWRITE_TAC[GSYM GROUP_MONOMORPHISM_EPIMORPHISM] THEN
  REWRITE_TAC[GROUP_MONOMORPHISM; GROUP_EPIMORPHISM] THEN MESON_TAC[]);;

let GROUP_ISOMORPHISM_ALT = prove
 (`!G G' (f:A->B).
      group_isomorphism (G,G') f <=>
      IMAGE f (group_carrier G) = group_carrier G' /\
      (!x y. x IN group_carrier G /\ y IN group_carrier G
             ==> f(group_op G x y) = group_op G' (f x) (f y)) /\
      (!x. x IN group_carrier G /\ f x = group_id G' ==> x = group_id G)`,
  REPEAT GEN_TAC THEN ASM_CASES_TAC `group_homomorphism (G,G') (f:A->B)` THENL
   [ALL_TAC;
    ASM_MESON_TAC[GROUP_HOMOMORPHISM; GROUP_ISOMORPHISM; SUBSET_REFL]] THEN
  ASM_REWRITE_TAC[GROUP_ISOMORPHISM_GROUP_KERNEL_GROUP_IMAGE;
                  group_kernel; group_image] THEN
  RULE_ASSUM_TAC(REWRITE_RULE[group_homomorphism]) THEN
  MP_TAC(ISPEC `G:A group` GROUP_ID) THEN ASM SET_TAC[]);;

let SUBGROUP_GROUP_KERNEL = prove
 (`!G G' (f:A->B).
        group_homomorphism(G,G') f ==> (group_kernel (G,G') f) subgroup_of G`,
  SIMP_TAC[group_homomorphism; subgroup_of; group_kernel; IN_ELIM_THM; SUBSET;
           FORALL_IN_IMAGE; GROUP_OP_LID; GROUP_ID; GROUP_OP;
           GROUP_INV_ID; GROUP_INV]);;

let SUBGROUP_GROUP_IMAGE = prove
 (`!G G' (f:A->B).
        group_homomorphism(G,G') f ==> (group_image (G,G') f) subgroup_of G'`,
  SIMP_TAC[group_homomorphism; subgroup_of; group_image; SUBSET;
           FORALL_IN_IMAGE; FORALL_IN_IMAGE_2; IN_IMAGE] THEN
  MESON_TAC[GROUP_OP; GROUP_INV; GROUP_ID]);;

let GROUP_KERNEL_TO_SUBGROUP_GENERATED = prove
 (`!G H s (f:A->B).
        group_kernel (G,subgroup_generated H s) f = group_kernel(G,H) f`,
  REWRITE_TAC[group_kernel; SUBGROUP_GENERATED]);;

let GROUP_IMAGE_TO_SUBGROUP_GENERATED = prove
 (`!G H s (f:A->B).
        group_image (G,subgroup_generated H s) f = group_image(G,H) f`,
  REWRITE_TAC[group_image]);;

let GROUP_KERNEL_FROM_SUBGROUP_GENERATED = prove
 (`!G H s f:A->B.
        s subgroup_of G
        ==> group_kernel(subgroup_generated G s,H) f =
            group_kernel(G,H) f INTER s`,
  SIMP_TAC[group_kernel; CARRIER_SUBGROUP_GENERATED_SUBGROUP] THEN
  REWRITE_TAC[subgroup_of] THEN SET_TAC[]);;

let GROUP_IMAGE_FROM_SUBGROUP_GENERATED = prove
 (`!G H s f:A->B.
        s subgroup_of G
        ==> group_image(subgroup_generated G s,H) f =
            group_image(G,H) f INTER IMAGE f s`,
  SIMP_TAC[group_image; CARRIER_SUBGROUP_GENERATED_SUBGROUP] THEN
  REWRITE_TAC[subgroup_of] THEN SET_TAC[]);;

let GROUP_ISOMORPHISM_ONTO_IMAGE = prove
 (`!(f:A->B) G H.
        group_isomorphism(G,subgroup_generated H (group_image (G,H) f)) f <=>
        group_monomorphism(G,H) f`,
  REPEAT GEN_TAC THEN REWRITE_TAC[GSYM GROUP_MONOMORPHISM_EPIMORPHISM] THEN
  REWRITE_TAC[group_monomorphism; group_epimorphism] THEN
  REWRITE_TAC[GROUP_HOMOMORPHISM_INTO_SUBGROUP_EQ_GEN] THEN
  ASM_CASES_TAC `group_homomorphism (G,H) (f:A->B)` THEN
  ASM_REWRITE_TAC[] THEN
  ASM_SIMP_TAC[CARRIER_SUBGROUP_GENERATED_SUBGROUP; SUBGROUP_GROUP_IMAGE] THEN
  REWRITE_TAC[group_image; SUBSET_REFL]);;

let NORMAL_SUBGROUP_GROUP_KERNEL = prove
 (`!G G' (f:A->B).
        group_homomorphism(G,G') f
        ==> (group_kernel (G,G') f) normal_subgroup_of G`,
  SIMP_TAC[NORMAL_SUBGROUP_CONJUGATE; SUBGROUP_GROUP_KERNEL] THEN
  REWRITE_TAC[group_homomorphism; group_setop] THEN REPEAT STRIP_TAC THEN
  REWRITE_TAC[SIMPLE_IMAGE; GSYM IMAGE_o; o_DEF;
      SET_RULE `{f x y | P x /\ y IN {a}} = {f x a | P x}`;
      SET_RULE `{f x y | x IN {a} /\ P y} = {f a y | P y}`] THEN
  REWRITE_TAC[SUBSET; FORALL_IN_IMAGE; group_kernel; IN_ELIM_THM] THEN
  RULE_ASSUM_TAC(REWRITE_RULE[SUBSET; FORALL_IN_IMAGE]) THEN
  ASM_SIMP_TAC[GROUP_INV; GROUP_OP; GROUP_OP_LID; GROUP_OP_LINV]);;

let GROUP_KERNEL_RIGHT_COSET = prove
 (`!G n:A->bool.
        n normal_subgroup_of G
        ==> group_kernel(G,quotient_group G n) (right_coset G n) = n`,
  REPEAT STRIP_TAC THEN ASM_SIMP_TAC[group_kernel; QUOTIENT_GROUP_ID] THEN
  FIRST_ASSUM(STRIP_ASSUME_TAC o GEN_REWRITE_RULE I [normal_subgroup_of]) THEN
  REWRITE_TAC[TAUT `p /\ q <=> ~(p ==> ~q)`] THEN
  ASM_SIMP_TAC[RIGHT_COSET_EQ_SUBGROUP] THEN
  FIRST_ASSUM(MP_TAC o MATCH_MP SUBGROUP_OF_IMP_SUBSET) THEN SET_TAC[]);;

let QUOTIENT_GROUP_UNIVERSAL = prove
 (`!G G' n (f:A->B).
        group_homomorphism (G,G') f /\ n normal_subgroup_of G /\
        (!x y. x IN group_carrier G /\ y IN group_carrier G /\
               right_coset G n x = right_coset G n y
               ==> f x = f y)
        ==> ?g. group_homomorphism(quotient_group G n,G') g /\
                !x. x IN group_carrier G ==> g(right_coset G n x) = f x`,
  REWRITE_TAC[group_homomorphism; SUBSET; FORALL_IN_IMAGE] THEN
  REPEAT STRIP_TAC THEN FIRST_ASSUM
   (MP_TAC o GSYM o GEN_REWRITE_RULE I [FUNCTION_FACTORS_LEFT_GEN]) THEN
  MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `g:(A->bool)->B` THEN
  DISCH_TAC THEN ASM_SIMP_TAC[QUOTIENT_GROUP] THEN
  REWRITE_TAC[IMP_CONJ; RIGHT_FORALL_IMP_THM; FORALL_IN_GSPEC] THEN
  ASM_SIMP_TAC[GROUP_SETINV_RIGHT_COSET; GROUP_SETOP_RIGHT_COSET] THEN
  ASM_SIMP_TAC[GROUP_OP; GROUP_INV] THEN
  SUBGOAL_THEN `n = right_coset G n (group_id G:A)` SUBST1_TAC THENL
   [ASM_MESON_TAC[RIGHT_COSET_ID; normal_subgroup_of;
                  SUBGROUP_OF_IMP_SUBSET];
    ASM_SIMP_TAC[GROUP_ID]]);;

let GROUP_KERNEL_FROM_TRIVIAL_GROUP = prove
 (`!G H (f:A->B).
        group_homomorphism (G,H) f /\ trivial_group G
        ==> group_kernel (G,H) f = group_carrier G`,
  REWRITE_TAC[trivial_group; group_kernel; group_homomorphism] THEN
  SET_TAC[]);;

let GROUP_IMAGE_FROM_TRIVIAL_GROUP = prove
 (`!G H (f:A->B).
        group_homomorphism (G,H) f /\ trivial_group G
        ==> group_image (G,H) f = {group_id H}`,
  REWRITE_TAC[trivial_group; group_image; group_homomorphism] THEN
  SET_TAC[]);;

let GROUP_KERNEL_TO_TRIVIAL_GROUP = prove
 (`!G H (f:A->B).
        group_homomorphism (G,H) f /\ trivial_group H
        ==> group_kernel (G,H) f = group_carrier G`,
  REWRITE_TAC[trivial_group; group_kernel; group_homomorphism] THEN
  SET_TAC[]);;

let GROUP_IMAGE_TO_TRIVIAL_GROUP = prove
 (`!G H (f:A->B).
        group_homomorphism (G,H) f /\ trivial_group H
        ==> group_image (G,H) f = group_carrier H`,
  REWRITE_TAC[trivial_group; group_image; group_homomorphism] THEN
  REPEAT STRIP_TAC THEN MATCH_MP_TAC SUBSET_ANTISYM THEN
  ASM_REWRITE_TAC[] THEN REWRITE_TAC[SING_SUBSET; IN_IMAGE] THEN
  ASM_MESON_TAC[GROUP_ID]);;

let FIRST_GROUP_ISOMORPHISM_THEOREM = prove
 (`!G G' (f:A->B).
        group_homomorphism(G,G') f
        ==> (quotient_group G (group_kernel (G,G') f)) isomorphic_group
            (subgroup_generated G' (group_image (G,G') f))`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[isomorphic_group; GROUP_ISOMORPHISM] THEN
  FIRST_ASSUM(MP_TAC o SPEC `group_kernel (G,G') (f:A->B)` o
    MATCH_MP (ONCE_REWRITE_RULE[IMP_CONJ] QUOTIENT_GROUP_UNIVERSAL)) THEN
  ASM_SIMP_TAC[NORMAL_SUBGROUP_GROUP_KERNEL] THEN ANTS_TAC THENL
   [ASM_SIMP_TAC[IMP_CONJ; RIGHT_COSET_EQ; SUBGROUP_GROUP_KERNEL];
    MATCH_MP_TAC MONO_EXISTS THEN
    X_GEN_TAC `g:(A->bool)->B` THEN STRIP_TAC THEN
    ASM_SIMP_TAC[GROUP_HOMOMORPHISM_INTO_SUBGROUP_EQ; SUBGROUP_GROUP_IMAGE;
             QUOTIENT_GROUP; NORMAL_SUBGROUP_GROUP_KERNEL;
             CARRIER_SUBGROUP_GENERATED_SUBGROUP; SUBGROUP_GROUP_KERNEL] THEN
    REWRITE_TAC[group_image] THEN
    REPEAT(CONJ_TAC THENL [ASM SET_TAC[]; ALL_TAC]) THEN
    SIMP_TAC[IMP_CONJ; RIGHT_FORALL_IMP_THM; FORALL_IN_GSPEC] THEN
    ASM_SIMP_TAC[RIGHT_COSET_EQ; SUBGROUP_GROUP_KERNEL]] THEN
  SIMP_TAC[group_kernel; IN_ELIM_THM; GROUP_DIV] THEN RULE_ASSUM_TAC
   (REWRITE_RULE[group_homomorphism; SUBSET; FORALL_IN_IMAGE]) THEN
  ASM_SIMP_TAC[group_div; GROUP_INV] THEN
  ASM_SIMP_TAC[GSYM group_div; GROUP_DIV_EQ_ID]);;