
open import Data.Unit 
open import Data.Product
open import Relation.Nullary 
open import Relation.Binary.PropositionalEquality


module Core.Core where

  postulate 
    Var : Set 
    _≡?_ : (x y : Var) -> Dec (x ≡ y) 

  data Binding : Set where 
    BHole : Binding
    BVar : Var -> Binding

  data BareType : Set where 
    BareTBase : BareType 
    BareTHole : BareType
    BareTArrow : BareType -> BareType -> BareType 
    BareTProd : BareType -> BareType -> BareType 
    BareTVar : Var -> BareType
    BareTForall : Binding -> BareType -> BareType

  data ProdSide : Set where 
    Fst : ProdSide 
    Snd : ProdSide

  data BareExp : Set where 
    BareEConst : BareExp 
    BareEHole : BareExp
    BareEFun : Binding -> BareType -> BareExp -> BareExp 
    BareEAp : BareExp -> BareExp -> BareExp 
    BareEVar : Var -> BareExp 
    BareEAsc : BareType -> BareExp -> BareExp 
    BareEPair : BareExp -> BareExp -> BareExp 
    BareEProj : ProdSide -> BareExp -> BareExp
    BareETypFun : Binding -> BareExp -> BareExp 
    BareETypAp : BareExp -> BareType -> BareExp

  data BareSubsumable : BareExp -> Set where 
    BareSubsumableConst : BareSubsumable BareEConst
    BareSubsumableHole : BareSubsumable BareEHole
    BareSubsumableAp : ∀ {e1 e2} -> BareSubsumable (BareEAp e1 e2) 
    BareSubsumableVar : ∀ {x} -> BareSubsumable (BareEVar x) 
    BareSubsumableAsc : ∀ {t e} -> BareSubsumable (BareEAsc t e) 
    BareSubsumableProj : ∀ {s e} -> BareSubsumable (BareEProj s e) 
    BareSubsumableTypAp : ∀ {e t} -> BareSubsumable (BareETypAp e t) 
    
  data Mark : Set where 
    ✖ : Mark
    ✔ : Mark
    
  _⊓M_ : Mark -> Mark -> Mark 
  ✔ ⊓M m = m
  ✖ ⊓M m = ✖

  data Type : Set where 
    TBase : Type 
    THole : Type
    TArrow : Type -> Type -> Type 
    TProd : Type -> Type -> Type 
    TVar : Var -> Mark -> Type
    TForall : Binding -> Type -> Type

  data Data : Set where 
    □ : Data
    ■ : Type -> Data

  data Dirtiness : Set where 
    • : Dirtiness 
    ★ : Dirtiness 

  _⊓_ : Dirtiness -> Dirtiness -> Dirtiness 
  • ⊓ n = n
  ★ ⊓ n = ★

  ○ : (A : Set) -> Set 
  ○ A = A × Dirtiness 

  ○Type : Set 
  ○Type = ○ Type 

  ○Data : Set 
  ○Data = ○ Data

  ○Mark : Set 
  ○Mark = ○ Mark

  mutual 

    data SynExp : Set where  
      _⇒_ : ConExp -> ○Data -> SynExp

    data ConExp : Set where 
      EConst : ConExp 
      EHole : ConExp
      EFun : Binding -> ○Type -> Mark -> Mark -> AnaExp -> ConExp 
      EAp : AnaExp -> Mark -> AnaExp -> ConExp 
      EVar : Var -> Mark -> ConExp 
      EAsc : ○Type -> AnaExp -> ConExp 
      EPair : AnaExp -> AnaExp -> Mark -> ConExp
      EProj : ProdSide -> AnaExp -> Mark -> ConExp
      ETypFun : Binding -> Mark -> AnaExp -> ConExp 
      ETypAp : AnaExp -> Mark -> ○Type -> ConExp

    data AnaExp : Set where 
      _[_]⇐_ : SynExp -> Mark -> ○Data -> AnaExp

  data Program : Set where 
    Root : SynExp -> Dirtiness -> Program
    
  AnaExpOfProgram : Program -> AnaExp  
  AnaExpOfProgram (Root e n) = (e [ ✔ ]⇐ (□ , n)) 

  data SubsumableMid : ConExp -> Set where 
    SubsumableConst : SubsumableMid EConst
    SubsumableHole : SubsumableMid EHole
    SubsumableAp : ∀ {e1 m e2} -> SubsumableMid (EAp e1 m e2) 
    SubsumableVar : ∀ {x m} -> SubsumableMid (EVar x m) 
    SubsumableAsc : ∀ {t e} -> SubsumableMid (EAsc t e) 
    SubsumableProj : ∀ {s e m} -> SubsumableMid (EProj s e m) 
    SubsumableTypAp : ∀ {e m t} -> SubsumableMid (ETypAp e m t) 

  Subsumable : SynExp -> Set 
  Subsumable (mid ⇒ _) = SubsumableMid mid

  data Context (A : Set) (free : A) : Set where 
    ∅ : Context A free
    _∶_∷_ : Var -> A -> Context A free -> Context A free
    _T∷_ : Var -> Context A free -> Context A free

  _∶_∷?_ : {A : Set} -> {free : A} -> Binding -> A -> Context A free -> Context A free
  BHole ∶ t ∷? Γ = Γ
  BVar x ∶ t ∷? Γ = x ∶ t ∷ Γ

  _T∷?_ : {A : Set} -> {free : A} -> Binding -> Context A free -> Context A free
  BHole T∷? Γ = Γ
  BVar x T∷? Γ = x T∷ Γ

  data _,_∈_,_ {A : Set} {free : A} : Var -> A -> Context A free -> Mark -> Set where 
    InCtxEmpty : ∀ {x} ->
      x , free ∈ ∅ , ✖ 
    InCtxFound : ∀ {Γ x a} ->
      x , a ∈ (x ∶ a ∷ Γ) , ✔
    InCtxSkip : ∀ {Γ a a' x x' m} -> 
      ¬(x ≡ x') ->
      (x , a ∈ Γ , m) -> 
      (x , a ∈ (x' ∶ a' ∷ Γ) , m)
    InCtxTSkip : ∀ {Γ a x x' m} -> 
      (x , a ∈ Γ , m) -> 
      (x , a ∈ (x' T∷ Γ) , m)

  _,_∈?_,_ : {A : Set} -> {free : A} -> Binding -> A -> Context A free -> Mark -> Set
  BHole , a ∈? Γ , m = ⊤
  BVar x , a ∈? Γ , m = x , a ∈ Γ , m

  data _T∈_,_  {A : Set} {free : A} : Var -> Context A free -> Mark -> Set where 
    InCtxEmpty : ∀ {x} ->
      x T∈ ∅ , ✖
    InCtxFound : ∀ {Γ x} ->
      x T∈ (x T∷ Γ) , ✔
    InCtxSkip : ∀ {Γ a x x' m} -> 
      (x T∈ Γ , m) -> 
      (x T∈ (x' ∶ a ∷ Γ) , m)
    InCtxTSkip : ∀ {Γ x x' m} -> 
      ¬(x ≡ x') ->
      (x T∈ Γ , m) -> 
      (x T∈ (x' T∷ Γ) , m)

  _T∈?_,_ : {A : Set} {free : A} -> Binding -> Context A free -> Mark -> Set
  BHole T∈? Γ , m = ⊤
  BVar x T∈? Γ , m = x T∈ Γ , m
    
  BareCtx : Set 
  BareCtx = Context Type THole

  Ctx : Set 
  Ctx = Context ○Type (THole , •)