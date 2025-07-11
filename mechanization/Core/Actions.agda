
open import Data.List 
open import Data.Product 

open import Core.Core
open import Core.WellFormed
open import Core.VariableUpdate
open import Core.TypVariableUpdate

module Core.Actions where

  data Child : Set where 
    One : Child
    Two : Child

  data Action : Set where 
    InsertConst : Action
    WrapFun : Action
    WrapAp : Child -> Action
    InsertVar : Var -> Action
    WrapAsc : Action
    WrapPair : Child -> Action
    WrapProj : ProdSide -> Action
    WrapTypFun : Action
    WrapTypAp : Action
    Delete : Action 
    Unwrap : Child -> Action
    InsertBase : Action
    WrapArrow : Child -> Action
    WrapProd : Child -> Action
    InsertTVar : Var -> Action
    WrapForall : Action
    DeleteBinder : Action
    InsertBinder : Var -> Action
    
  LocalizedAction : Set
  LocalizedAction = Action × (List Child)

  
  data _,_αBT↦_ : Action -> BareType -> BareType -> Set where
    ActInsertBase :
      InsertBase , BareTHole αBT↦ BareTBase
    ActWrapArrowOne : ∀ {t} ->
      (WrapArrow One) , t αBT↦ (BareTArrow t BareTHole)
    ActWrapArrowTwo : ∀ {t} ->
      (WrapArrow Two) , t αBT↦ (BareTArrow BareTHole t)
    ActWrapProdOne : ∀ {t} ->
      (WrapProd One) , t αBT↦ (BareTProd t BareTHole)
    ActWrapProdTwo : ∀ {t} ->
      (WrapProd Two) , t αBT↦ (BareTProd BareTHole t)
    ActInsertTVar : ∀ {x} ->
      (InsertTVar x) , BareTHole αBT↦ (BareTVar x)
    ActWrapForall : ∀ {t} ->
      WrapForall , t αBT↦ (BareTForall BHole t)
    ActUnwrapArrowOne : ∀ {t} ->
      (Unwrap One) , (BareTArrow t BareTHole) αBT↦ t
    ActUnwrapArrowTwo : ∀ {t} ->
      (Unwrap Two) , (BareTArrow BareTHole t) αBT↦ t
    ActUnwrapProdOne : ∀ {t} ->
      (Unwrap One) , (BareTProd t BareTHole) αBT↦ t
    ActUnwrapProdTwo : ∀ {t} ->
      (Unwrap Two) , (BareTProd BareTHole t) αBT↦ t
    ActUnwrapForall : ∀ {t} ->
      (Unwrap One) , (BareTForall BHole t) αBT↦ t
    ActDelete : ∀ {t} ->
      Delete , t αBT↦ BareTHole
    ActDeleteBinder : ∀ {x? t} ->
      DeleteBinder , (BareTForall x? t) αBT↦ (BareTForall BHole t)
    ActInsertBinder : ∀ {x t} ->
      InsertBinder x , (BareTForall BHole t) αBT↦ (BareTForall (BVar x) t)

  data _,_ABT↦_ : LocalizedAction -> BareType -> BareType -> Set where
    ATBareDone : ∀ {α t t'} ->
      α , t αBT↦ t' ->
      (α , []) , t ABT↦ t'
    ABareArrowOne : ∀ {α l t1 t2 t1'} ->
      (α , l) , t1 ABT↦ t1' ->
      (α , One ∷ l) , (BareTArrow t1 t2) ABT↦ (BareTArrow t1' t2)
    ABareArrowTwo : ∀ {α l t1 t2 t2'} ->
      (α , l) , t2 ABT↦ t2' ->
      (α , Two ∷ l) , (BareTArrow t1 t2) ABT↦ (BareTArrow t1 t2')
    ABareProdOne : ∀ {α l t1 t2 t1'} ->
      (α , l) , t1 ABT↦ t1' ->
      (α , One ∷ l) , (BareTProd t1 t2) ABT↦ (BareTProd t1' t2)
    ABareProdTwo : ∀ {α l t1 t2 t2'} ->
      (α , l) , t2 ABT↦ t2' ->
      (α , Two ∷ l) , (BareTProd t1 t2) ABT↦ (BareTProd t1 t2')
    ABareForall : ∀ {α l x t t'} ->
      (α , l) , t ABT↦ t' ->
      (α , One ∷ l) , (BareTForall x t) ABT↦ (BareTForall x t')
  
  data _,_ABT↦*_ : (List LocalizedAction) -> BareType -> BareType -> Set where 
    ABT*StepAct : ∀{A As e e' e''} ->
      A , e ABT↦ e' -> 
      As , e' ABT↦* e'' ->
      (A ∷ As) , e ABT↦* e'' 
    ABT*StepDone : ∀{e} ->
      [] , e ABT↦* e

  data _,_αB↦_ : Action -> BareExp -> BareExp -> Set where
    ActInsertConst : 
      InsertConst , BareEHole αB↦ BareEConst
    ActWrapFun : ∀ {e} ->
      WrapFun , e αB↦ (BareEFun BHole BareTHole e)
    ActWrapApOne : ∀ {e} ->
      (WrapAp One) , e αB↦ (BareEAp e BareEHole)
    ActWrapApTwo : ∀ {e} ->
      (WrapAp Two) , e αB↦ (BareEAp BareEHole e)
    ActInsertVar : ∀ {x} ->
      (InsertVar x) , BareEHole αB↦ (BareEVar x)
    ActWrapAsc : ∀ {e} ->
      WrapAsc , e αB↦ (BareEAsc BareTHole e)
    ActWrapPairOne : ∀ {e} ->
      (WrapPair One) , e αB↦ (BareEPair e BareEHole)
    ActWrapPairTwo : ∀ {e} ->
      (WrapPair Two) , e αB↦ (BareEPair BareEHole e)
    ActWrapProj : ∀ {s e} -> 
      (WrapProj s) , e αB↦ (BareEProj s e)
    ActWrapTypFun : ∀ {e} ->
      WrapTypFun , e αB↦ (BareETypFun BHole e)
    ActWrapTypAp : ∀ {e} ->
      WrapTypAp , e αB↦ (BareETypAp e BareTHole)
    ActDelete : ∀ {e} ->
      Delete , e αB↦ BareEHole
    ActUnwrapFun : ∀ {x asc e} ->
      (Unwrap One) , (BareEFun x asc e) αB↦ e
    ActUnwrapApOne : ∀ {e e-arg} ->
      (Unwrap One) , (BareEAp e e-arg) αB↦ e
    ActUnwrapApTwo : ∀ {e e-fun} ->
      (Unwrap Two) , (BareEAp e-fun e) αB↦ e
    ActUnwrapAsc : ∀ {asc e} ->
      (Unwrap One) , (BareEAsc asc e) αB↦ e
    ActUnwrapPairOne : ∀ {e e-arg} ->
      (Unwrap One) , (BareEPair e e-arg) αB↦ e
    ActUnwrapPairTwo : ∀ {e e-fun} ->
      (Unwrap Two) , (BareEPair e-fun e) αB↦ e
    ActUnwrapProj : ∀ {s e} ->
      (Unwrap One) , (BareEProj s e) αB↦ e
    ActUnwrapTypFun : ∀ {x e} ->
      (Unwrap One) , (BareETypFun x e) αB↦ e
    ActUnwrapTypAp : ∀ {e t-arg} ->
      (Unwrap One) , (BareETypAp e t-arg) αB↦ e
    ActDeleteBinder : ∀ {x e t} ->
      DeleteBinder , (BareEFun x t e) αB↦ (BareEFun BHole t e)
    ActInsertBinder : ∀ {x e t} ->
      InsertBinder x , (BareEFun BHole t e) αB↦ (BareEFun (BVar x) t e)
    ActDeleteTypBinder : ∀ {x e} ->
      DeleteBinder , (BareETypFun x e) αB↦ (BareETypFun BHole e)
    ActInsertTypBinder : ∀ {x e} ->
      InsertBinder x , (BareETypFun BHole e) αB↦ (BareETypFun (BVar x) e)

  data _,_AB↦_ : LocalizedAction -> BareExp -> BareExp -> Set where
    ABareDone : ∀ {α e e'} ->
      α , e αB↦ e' ->
      (α , []) , e AB↦ e'
    ABareAscOne : ∀ {α l t t' e} ->
      (α , l) , t ABT↦ t' ->
      (α , One ∷ l) , (BareEAsc t e) AB↦ (BareEAsc t' e)
    ABareAscTwo : ∀ {α l e e' a1} ->
      (α , l) , e AB↦ e' ->
      (α , Two ∷ l) , (BareEAsc a1 e) AB↦ (BareEAsc a1 e')
    ABareFunOne : ∀ {α l e t t' x} ->
      (α , l) , t ABT↦ t' ->
      (α , One ∷ l) , (BareEFun x t e) AB↦ (BareEFun x t' e)
    ABareFunTwo : ∀ {α l e e' x t} ->
      (α , l) , e AB↦ e' ->
      (α , Two ∷ l) , (BareEFun x t e) AB↦ (BareEFun x t e')
    ABareApOne : ∀ {α l e1 e2 e1'} ->
      (α , l) , e1 AB↦ e1' ->
      (α , One ∷ l) , (BareEAp e1 e2) AB↦ (BareEAp e1' e2)
    ABareApTwo : ∀ {α l e1 e2 e2'} ->
      (α , l) , e2 AB↦ e2' ->
      (α , Two ∷ l) , (BareEAp e1 e2) AB↦ (BareEAp e1 e2')
    ABarePairOne : ∀ {α l e1 e2 e1'} ->
      (α , l) , e1 AB↦ e1' ->
      (α , One ∷ l) , (BareEPair e1 e2) AB↦ (BareEPair e1' e2)
    ABarePairTwo : ∀ {α l e1 e2 e2'} ->
      (α , l) , e2 AB↦ e2' ->
      (α , Two ∷ l) , (BareEPair e1 e2) AB↦ (BareEPair e1 e2')
    ABareProj : ∀ {α l e e' s} ->
      (α , l) , e AB↦ e' ->
      (α , One ∷ l) , (BareEProj s e) AB↦ (BareEProj s e')
    ABareTypFun : ∀ {α l e e' a1} ->
      (α , l) , e AB↦ e' ->
      (α , One ∷ l) , (BareETypFun a1 e) AB↦ (BareETypFun a1 e')
    ABareTypApOne : ∀ {α l e e' a1} ->
      (α , l) , e AB↦ e' ->
      (α , One ∷ l) , (BareETypAp e a1) AB↦ (BareETypAp e' a1)
    ABareTypApTwo : ∀ {α l t t' a1} ->
      (α , l) , t ABT↦ t' ->
      (α , Two ∷ l) , (BareETypAp a1 t) AB↦ (BareETypAp a1 t')
  
  data _,_AB↦*_ : (List LocalizedAction) -> BareExp -> BareExp -> Set where 
    AB*StepAct : ∀{A As e e' e''} ->
      A , e AB↦ e' -> 
      As , e' AB↦* e'' ->
      (A ∷ As) , e AB↦* e'' 
    AB*StepDone : ∀{e} ->
      [] , e AB↦* e

  data _⊢_,_αT↦_ : Ctx -> Action -> Type -> Type -> Set where 
    ActInsertBase : ∀ {Γ} ->
      Γ ⊢ InsertBase , THole αT↦ TBase
    ActWrapArrowOne : ∀ {Γ t} ->
      Γ ⊢ (WrapArrow One) , t αT↦ (TArrow t THole)
    ActWrapArrowTwo : ∀ {Γ t} ->
      Γ ⊢ (WrapArrow Two) , t αT↦ (TArrow THole t)
    ActWrapProdOne : ∀ {Γ t} ->
      Γ ⊢ (WrapProd One) , t αT↦ (TProd t THole)
    ActWrapProdTwo : ∀ {Γ t} ->
      Γ ⊢ (WrapProd Two) , t αT↦ (TProd THole t)
    ActInsertTVar : ∀ {Γ x m} ->
      x T∈ Γ , m ->
      Γ ⊢ (InsertTVar x) , THole αT↦ (TVar x m)
    ActWrapForall : ∀ {Γ t} ->
      Γ ⊢ WrapForall , t αT↦ (TForall BHole t)
    ActUnwrapArrowOne : ∀ {Γ t} ->
      Γ ⊢ (Unwrap One) , (TArrow t THole) αT↦ t
    ActUnwrapArrowTwo : ∀ {Γ t} ->
      Γ ⊢ (Unwrap Two) , (TArrow THole t) αT↦ t
    ActUnwrapProdOne : ∀ {Γ t} ->
      Γ ⊢ (Unwrap One) , (TProd t THole) αT↦ t
    ActUnwrapProdTwo : ∀ {Γ t} ->
      Γ ⊢ (Unwrap Two) , (TProd THole t) αT↦ t
    ActUnwrapForall : ∀ {Γ t} ->
      Γ ⊢ (Unwrap One) , (TForall BHole t) αT↦ t
    ActDelete : ∀ {Γ t} ->
      Γ ⊢ Delete , t αT↦ THole
    ActDeleteBinder : ∀ {Γ x? m t t'} ->
      x? T∈? Γ , m ->
      TypVariableUpdate? x? m t t' ->
      Γ ⊢ DeleteBinder , (TForall x? t) αT↦ (TForall BHole t')
    ActInsertBinder : ∀ {Γ x t t'} ->
      TypVariableUpdate x ✔ t t' ->
      Γ ⊢ InsertBinder x , (TForall BHole t) αT↦ (TForall (BVar x) t')

  data _⊢_,_AT↦_ : (Γ : Ctx) -> (α : LocalizedAction) -> (t : Type) -> (t' : Type) -> Set where 
    ATDone : ∀ {Γ α t t'} ->
      Γ ⊢ α , t αT↦ t' ->
      Γ ⊢ (α , []) , t AT↦ t'
    AArrowOne : ∀ {Γ α l t1 t2 t1'} ->
      Γ ⊢ (α , l) , t1 AT↦ t1' ->
      Γ ⊢ (α , One ∷ l) , (TArrow t1 t2) AT↦ (TArrow t1' t2)
    AArrowTwo : ∀ {Γ α l t1 t2 t2'} ->
      Γ ⊢ (α , l) , t2 AT↦ t2' ->
      Γ ⊢ (α , Two ∷ l) , (TArrow t1 t2) AT↦ (TArrow t1 t2')
    AProdOne : ∀ {Γ α l t1 t2 t1'} ->
      Γ ⊢ (α , l) , t1 AT↦ t1' ->
      Γ ⊢ (α , One ∷ l) , (TProd t1 t2) AT↦ (TProd t1' t2)
    AProdTwo : ∀ {Γ α l t1 t2 t2'} ->
      Γ ⊢ (α , l) , t2 AT↦ t2' ->
      Γ ⊢ (α , Two ∷ l) , (TProd t1 t2) AT↦ (TProd t1 t2')
    AForall : ∀ {Γ α l x t t'} ->
      (x T∷? Γ) ⊢ (α , l) , t AT↦ t' ->
      Γ ⊢ (α , One ∷ l) , (TForall x t) AT↦ (TForall x t')

  data _⊢_,_αS↦_ : Ctx -> Action -> SynExp -> SynExp -> Set where 
    ActInsertConst : ∀ {Γ syn} ->
      Γ ⊢ InsertConst , (EHole ⇒ syn) αS↦ (EConst ⇒ (■ TBase , ★))
    ActWrapFun : ∀ {Γ e t n} ->
      Γ ⊢ WrapFun , (e ⇒ (t , n)) αS↦ ((EFun BHole (THole , •) ✔ ✔ ((e ⇒ (t , ★)) [ ✔ ]⇐ (□ , ★))) ⇒ (□ , ★))
    ActWrapApOne : ∀ {Γ e t n} ->
      Γ ⊢ (WrapAp One) , (e ⇒ (t , n)) αS↦ ((EAp ((e ⇒ (t , ★)) [ ✔ ]⇐ (□ , ★)) ✔ ((EHole ⇒ (■ THole , •)) [ ✔ ]⇐ (□ , •))) ⇒ (□ , ★))
    ActWrapApTwo : ∀ {Γ e t n} ->
      Γ ⊢ (WrapAp Two) , (e ⇒ (t , n)) αS↦ ((EAp ((EHole ⇒ (■ THole , ★)) [ ✔ ]⇐ (□ , •)) ✔ ((e ⇒ (t , •)) [ ✔ ]⇐ (□ , ★))) ⇒ (□ , ★))
    ActWrapPairOne : ∀ {Γ e t n} -> 
      Γ ⊢ (WrapPair One) , (e ⇒ (t , n)) αS↦ ((EPair ((e ⇒ (t , ★)) [ ✔ ]⇐ (□ , ★)) ((EHole ⇒ (■ THole , ★)) [ ✔ ]⇐ (□ , •)) ✔ ) ⇒ (□ , ★))
    ActWrapPairTwo : ∀ {Γ e t n} -> 
      Γ ⊢ (WrapPair Two) , (e ⇒ (t , n)) αS↦ ((EPair ((EHole ⇒ (■ THole , ★)) [ ✔ ]⇐ (□ , •)) ((e ⇒ (t , ★)) [ ✔ ]⇐ (□ , ★)) ✔ ) ⇒ (□ , ★))
    ActWrapProj : ∀ {Γ s e t n} -> 
      Γ ⊢ (WrapProj s) , (e ⇒ (t , n)) αS↦ ((EProj s ((e ⇒ (t , ★)) [ ✔ ]⇐ (□ , ★)) ✔) ⇒ (□ , ★))
    ActWrapTypFun : ∀ {Γ e t n} ->
      Γ ⊢ WrapTypFun , (e ⇒ (t , n)) αS↦ ((ETypFun BHole ✔ ((e ⇒ (t , ★)) [ ✔ ]⇐ (□ , ★))) ⇒ (□ , ★))
    ActWrapTypAp : ∀ {Γ e t n} ->
      Γ ⊢ WrapTypAp , (e ⇒ (t , n)) αS↦ ((ETypAp ((e ⇒ (t , ★)) [ ✔ ]⇐ (□ , ★)) ✔ (THole , •)) ⇒ (□ , ★))
    ActInsertVar : ∀ {Γ syn x n t m} ->
      x , (t , n) ∈ Γ , m ->
      Γ ⊢ (InsertVar x) , (EHole ⇒ syn) αS↦ ((EVar x m) ⇒ (■ t , ★))
    ActWrapAsc : ∀ {Γ e syn} ->
      Γ ⊢ WrapAsc , (e ⇒ syn) αS↦ ((EAsc (THole , •) ((e ⇒ syn) [ ✔ ]⇐ (■ THole , ★))) ⇒ (■ THole , ★))
    ActDelete : ∀ {Γ e} ->
      Γ ⊢ Delete , e αS↦ (EHole ⇒ (■ THole , ★))
    ActUnwrapFun : ∀ {Γ x asc m-ana m-ann e e' t' n' tx nx m m-body ana syn} ->
      x , (tx , nx) ∈? Γ , m ->
      VariableUpdate? x tx m e (e' ⇒ (t' , n')) ->
      Γ ⊢ (Unwrap One) , ((EFun x asc m-ana m-ann (e [ m-body ]⇐ ana)) ⇒ syn) αS↦ (e' ⇒ (t' , ★))
    ActUnwrapApOne : ∀ {Γ e t n m ana e-arg syn m'} ->
      Γ ⊢ (Unwrap One) , ((EAp ((e ⇒ (t , n)) [ m ]⇐ ana) m' e-arg) ⇒ syn) αS↦ (e ⇒ (t , ★))
    ActUnwrapApTwo : ∀ {Γ e t n m ana e-fun syn m'} ->
      Γ ⊢ (Unwrap Two) , ((EAp e-fun m' ((e ⇒ (t , n)) [ m ]⇐ ana)) ⇒ syn) αS↦ (e ⇒ (t , ★))
    ActUnwrapAsc : ∀ {Γ asc e t n m ana syn} ->
      Γ ⊢ (Unwrap One) , ((EAsc asc ((e ⇒ (t , n)) [ m ]⇐ ana)) ⇒ syn) αS↦ (e ⇒ (t , ★))
    ActUnwrapPairOne : ∀ {Γ e t n m ana e-snd syn m'} ->
      Γ ⊢ (Unwrap One) , ((EPair ((e ⇒ (t , n)) [ m ]⇐ ana) e-snd m') ⇒ syn) αS↦ (e ⇒ (t , ★))
    ActUnwrapPairTwo : ∀ {Γ e t n m ana e-fst syn m'} ->
      Γ ⊢ (Unwrap Two) , ((EPair e-fst ((e ⇒ (t , n)) [ m ]⇐ ana) m') ⇒ syn) αS↦ (e ⇒ (t , ★))
    ActUnwrapProj : ∀ {Γ e t s n m ana syn m'} ->
      Γ ⊢ (Unwrap One) , ((EProj s ((e ⇒ (t , n)) [ m ]⇐ ana) m') ⇒ syn) αS↦ (e ⇒ (t , ★))
    ActUnwrapTypFun : ∀ {Γ x m-ana e e' t' n' m m-body ana syn} ->
      x T∈? Γ , m ->
      ExpTypVariableUpdate? x m e (e' ⇒ (t' , n')) ->
      Γ ⊢ (Unwrap One) , ((ETypFun x m-ana (e [ m-body ]⇐ ana)) ⇒ syn) αS↦ (e' ⇒ (t' , ★))
    ActUnwrapTypAp : ∀ {Γ e t n m ana t-arg syn m'} ->
      Γ ⊢ (Unwrap One) , ((ETypAp ((e ⇒ (t , n)) [ m ]⇐ ana) m' t-arg) ⇒ syn) αS↦ (e ⇒ (t , ★))
    -- ActSetAsc : ∀ {Γ asc e t syn} ->
    --   Γ ⊢ (SetAsc t) , ((EAsc asc e) ⇒ syn) αS↦ ((EAsc (t , ★) e) ⇒ syn)
    -- ActSetAnn : ∀ {Γ x e t ann m1 m2 syn} ->
    --   Γ ⊢ (SetAnn t) , ((EFun x ann m1 m2 e) ⇒ syn) αS↦ ((EFun x (t , ★) m1 m2 e) ⇒ syn)
    ActDeleteBinder : ∀ {Γ x tx nx m ann m1 m2 e e' t' n' syn ana} ->
      x , (tx , nx) ∈? Γ , m ->
      VariableUpdate? x tx m e (e' ⇒ (t' , n')) ->
      Γ ⊢ DeleteBinder , ((EFun x ann m1 m2 (e [ m ]⇐ ana)) ⇒ syn) αS↦ ((EFun BHole ann m1 m2 ((e' ⇒ (t' , ★)) [ m ]⇐ ana)) ⇒ syn)
    ActInsertBinder : ∀ {Γ x ann n-ann m1 m2 e e' t' n' syn m ana} ->
      VariableUpdate x ann ✔ e (e' ⇒ (t' , n')) ->
      Γ ⊢ InsertBinder x , ((EFun BHole (ann , n-ann) m1 m2 (e [ m ]⇐ ana)) ⇒ syn) αS↦ ((EFun (BVar x) (ann , n-ann) m1 m2 ((e' ⇒ (t' , ★)) [ m ]⇐ ana)) ⇒ syn)
    ActDeleteTypBinder : ∀ {Γ x m m1 e e' t' n' syn ana} ->
      x T∈? Γ , m ->
      ExpTypVariableUpdate? x m e (e' ⇒ (t' , n')) ->
      Γ ⊢ DeleteBinder , ((ETypFun x m1 (e [ m ]⇐ ana)) ⇒ syn) αS↦ ((ETypFun BHole m1 ((e' ⇒ (t' , ★)) [ m ]⇐ ana)) ⇒ syn)
    ActInsertTypBinder : ∀ {Γ x m1 e e' t' n' syn m ana} ->
      ExpTypVariableUpdate x ✔ e (e' ⇒ (t' , n')) ->
      Γ ⊢ InsertBinder x , ((ETypFun BHole m1 (e [ m ]⇐ ana)) ⇒ syn) αS↦ ((ETypFun (BVar x) m1 ((e' ⇒ (t' , ★)) [ m ]⇐ ana)) ⇒ syn)

  data _⊢_,_αA↦_ : Ctx -> Action -> AnaExp -> AnaExp -> Set where 
    ALC : ∀ {Γ α e e' m t n} ->
        Γ ⊢ α , e  αS↦ e' ->
        Γ ⊢ α , e [ m ]⇐ (t , n) αA↦ (e' [ m ]⇐ (t , ★))

  mutual 

    data _⊢_,_AS↦_ : (Γ : Ctx) -> (α : LocalizedAction) -> (e : SynExp) -> (e' : SynExp) -> Set where
      AUpMid : ∀ {Γ α e e' syn} ->
        Γ ⊢ α , e  AM↦ e' ->
        Γ ⊢ α , (e ⇒ syn) AS↦ (e' ⇒ syn) 

    data _⊢_,_AM↦_ : (Γ : Ctx) -> (α : LocalizedAction) -> (e : ConExp) -> (e' : ConExp) -> Set where 
      AMidAscOne : ∀ {Γ α l e t t' n} ->
        Γ ⊢ (α , l) , t AT↦ t' ->
        Γ ⊢ (α , One ∷ l) , (EAsc (t , n) e) AM↦ (EAsc (t' , ★) e)
      AMidAscTwo : ∀ {Γ α l e e' a1} ->
        Γ ⊢ (α , l) , e AA↦ e' ->
        Γ ⊢ (α , Two ∷ l) , (EAsc a1 e) AM↦ (EAsc a1 e')
      AMidFunOne : ∀ {Γ α l e t' x t n m1 m2} ->
        Γ ⊢ (α , l) , t AT↦ t' ->
        Γ ⊢ (α , One ∷ l) , (EFun x (t , n) m1 m2 e) AM↦ (EFun x (t' , ★) m1 m2 e)
      AMidFunTwo : ∀ {Γ α l e e' x t m1 m2} ->
        (x ∶ t ∷? Γ) ⊢ (α , l) , e AA↦ e' ->
        Γ ⊢ (α , Two ∷ l) , (EFun x t m1 m2 e) AM↦ (EFun x t m1 m2 e')
      AMidApOne : ∀ {Γ α l e1 e2 e1' m} ->
        Γ ⊢ (α , l) , e1 AA↦ e1' ->
        Γ ⊢ (α , One ∷ l) , (EAp e1 m e2) AM↦ (EAp e1' m e2)
      AMidApTwo : ∀ {Γ α l e1 e2 e2' m} ->
        Γ ⊢ (α , l) , e2 AA↦ e2' ->
        Γ ⊢ (α , Two ∷ l) , (EAp e1 m e2) AM↦ (EAp e1 m e2')
      AMidPairOne : ∀ {Γ α l e1 e2 e1' m} ->
        Γ ⊢ (α , l) , e1 AA↦ e1' ->
        Γ ⊢ (α , One ∷ l) , (EPair e1 e2 m) AM↦ (EPair e1' e2 m)
      AMidPairTwo : ∀ {Γ α l e1 e2 e2' m} ->
        Γ ⊢ (α , l) , e2 AA↦ e2' ->
        Γ ⊢ (α , Two ∷ l) , (EPair e1 e2 m) AM↦ (EPair e1 e2' m)
      AMidProj : ∀ {Γ α l s e e' m} -> 
        Γ ⊢ (α , l) , e AA↦ e' ->
        Γ ⊢ (α , One ∷ l) , (EProj s e m) AM↦ (EProj s e' m)

    data _⊢_,_AA↦_ : (Γ : Ctx) -> (α : LocalizedAction) -> (e : AnaExp) -> (e' : AnaExp) -> Set where
      ALowDone : ∀ {Γ α e e'} ->
        Γ ⊢ α , e αA↦ e' ->
        Γ ⊢ (α , []) , e AA↦ e'
      ALowUp : ∀ {Γ α e e' m ana} ->
        Γ ⊢ α , e  AS↦ e' ->
        Γ ⊢ α , e [ m ]⇐ ana AA↦ (e' [ m ]⇐ ana)

  data _,_AP↦_ : (α : LocalizedAction) -> (p p' : Program) -> Set where
    AStepProgram : ∀{α p p'} ->
      ∅ ⊢ α , (AnaExpOfProgram p) AA↦ (AnaExpOfProgram p') ->
      α , p AP↦ p'

