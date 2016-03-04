open import Util hiding (tail) 
module Subset.VectorRep where

--open import Level
open import Data.Bool
open import Relation.Binary.PropositionalEquality
open import Relation.Nullary
open import Data.Nat
open import Data.Product hiding (map)
open import Data.Sum hiding (map)
open import Data.Vec
open import Data.Unit
open import Data.Empty

∈-lem₁ : {A : Set}(a x : A){n : ℕ} → (as : Vec A n) → a ∈ x ∷ as → ¬ a ∈ as → a ≡ x
∈-lem₁ x .x as here a∉as         = refl
∈-lem₁ a  x as (there a∈as) a∉as = ⊥-elim (a∉as a∈as)

infix 4 _∈?_
_∈?_ : {A : Set}(a : A){n : ℕ} → (as : Vec A n) → {{dec : DecEq A}} → Dec (a ∈ as)
(a ∈? [])        {{dec}} = no (λ ())
(a ∈? ( x ∷ as)) {{dec}} with dec a x
(a ∈? (.a ∷ as)) {{dec}} | yes refl = yes here
(a ∈? ( x ∷ as)) {{dec}} | no  _    with (a ∈? as) {{dec}}
(a ∈? ( x ∷ as)) {{dec}} | no  _    | yes a∈as = yes (there a∈as)
(a ∈? ( x ∷ as)) {{dec}} | no  a≢x  | no  a∉as = no (λ a∈xas →  a≢x (∈-lem₁ a x as a∈xas a∉as))

Unique : {A : Set}{n : ℕ}(as : Vec A (suc n)) → Set
Unique (a ∷ []) = ⊤
Unique (a ∷ (b ∷ as)) = ¬ a ∈ (b ∷ as) × Unique (b ∷ as)

Unique-lem₁ : {A B : Set}{n : ℕ}(f : A → B) → Injective f → (as : Vec A (suc n)) → Unique as → Unique (map f as)
Unique-lem₁ f f-inj (a ∷ [])     un-as = tt
Unique-lem₁ f f-inj (a ∷ x ∷ as) un-as = prf f f-inj a x as (proj₁ un-as) , (Unique-lem₁ f f-inj (x ∷ as) (proj₂ un-as))
  where
    lem₁ : {A : Set}{a x : A} → a ∈ x ∷ [] → a ≡ x
    lem₁ here = refl
    lem₁ (there ())
    lem₂ : {A : Set}{n : ℕ}{a x : A}{as : Vec A n} → ¬ a ∈ x ∷ as → a ≢ x
    lem₂ a∉xas refl = a∉xas here
    lem₃ : {A : Set}{n : ℕ}{a x : A}{as : Vec A n} → a ∈ x ∷ as → a ≡ x ⊎ a ∈ as
    lem₃ here = inj₁ refl
    lem₃ (there prf) = inj₂ prf
    lem₄ : {A : Set}{n : ℕ}{a x : A}{as : Vec A n} → ¬ a ∈ x ∷ as → ¬ a ∈ as
    lem₄ a∉xas here = a∉xas (there here)
    lem₄ a∉xas (there prf) = lem₄ (λ z → a∉xas (there z)) prf
    prf : {A B : Set}{n : ℕ}(f : A → B) → Injective f → (a x : A)(as : Vec A n) → ¬ a ∈ x ∷ as → ¬ f a ∈ f x ∷ (map f as)
    prf f f-inj a x []       ¬a∈xas fafxas = let a≢x = lem₂ ¬a∈xas in Injective-lem₁ f-inj a≢x (lem₁ fafxas)
    prf f f-inj a x (y ∷ as) ¬a∈xas fafxas with lem₃ fafxas
    ... | inj₁ fa≡fx   = let a≢x = lem₂ ¬a∈xas in Injective-lem₁ f-inj a≢x fa≡fx
    ... | inj₂ fa∈fyas = prf f f-inj a y as (lem₄ ¬a∈xas) fa∈fyas


∈-lem₂ : {A B : Set}{n : ℕ}(decA : DecEq A)(decB : DecEq B)(f : A → B) → (a : A)(as : Vec A n)
         → (a ∈ as) → (f a ∈ map f as)
∈-lem₂ decA decB f a ._ here               = here
∈-lem₂ decA decB f a (y ∷ as) (there a∈as) = there (∈-lem₂ decA decB f a as a∈as)

∈-lem₃ : {A : Set}{n m : ℕ}(dec : DecEq A)(a : A)(as : Vec A n)(bs : Vec A m)
         → a ∈ as ++ bs → a ∈ as ⊎ a ∈ bs
∈-lem₃ dec a []        bs a∈asbs = inj₂ a∈asbs
∈-lem₃ dec x (.x ∷ as) bs here = inj₁ here
∈-lem₃ dec a ( x ∷ as) bs (there a∈asbs) with ∈-lem₃ dec a as bs a∈asbs
∈-lem₃ dec a ( x ∷ as) bs (there a∈asbs) | inj₁ a∈as = inj₁ (there a∈as)
∈-lem₃ dec a ( x ∷ as) bs (there a∈asbs) | inj₂ a∈bs = inj₂ a∈bs

∈-lem₄ : {A : Set}{n m : ℕ}(dec : DecEq A)(a : A)(as : Vec A n)(bs : Vec A m)
         → a ∈ as → a ∈ as ++ bs
∈-lem₄ dec x (.x ∷ as) bs here = here
∈-lem₄ dec a ( x ∷ as) bs (there a∈as) = there (∈-lem₄ dec a as bs a∈as)

∈-lem₅ : {A : Set}{n m : ℕ}(dec : DecEq A)(a : A)(as : Vec A n)(bs : Vec A m)
         → a ∈ bs → a ∈ as ++ bs
∈-lem₅ dec a []        bs a∈bs = a∈bs
∈-lem₅ dec a ( x ∷ as) bs a∈bs with dec a x
∈-lem₅ dec a (.a ∷ as) bs a∈bs | yes refl = here
∈-lem₅ dec a ( x ∷ as) bs a∈bs | no  _    = there (∈-lem₅ dec a as bs a∈bs)

∈-lem₆ : {A : Set}{n m : ℕ}(dec : DecEq A)(a : A)(as : Vec A n)(bs : Vec A m)
         → a ∈ as ⊎ a ∈ bs → a ∈ as ++ bs
∈-lem₆ dec a as bs (inj₁ a∈as) = ∈-lem₄ dec a as bs a∈as
∈-lem₆ dec a as bs (inj₂ a∈bs) = ∈-lem₅ dec a as bs a∈bs

any : {A : Set}{n : ℕ}(P : A → Set) → Vec A n → Set
any P []       = ⊥
any P (a ∷ as) = P a ⊎ any P as

any-lem₁ : {A : Set}{n : ℕ}(as : Vec A n) → ∀ P → any P as → Σ[ a ∈ A ] P a
any-lem₁ []       P    ()
any-lem₁ (a ∷ as) P (inj₁ Pa)    = a , Pa
any-lem₁ (a ∷ as) P (inj₂ apply) = any-lem₁ as P apply

any-lem₂ : {A : Set}{n : ℕ}(as : Vec A n) → ∀ P → Σ[ a ∈ A ] (P a × a ∈ as) → any P as
any-lem₂ []       P ( a , Pa , ())
any-lem₂ (a ∷ as) P (.a , Pa , here)       = inj₁ Pa
any-lem₂ (a ∷ as) P ( x , Pa , there a∈as) = inj₂ (any-lem₂ as P (x , Pa , a∈as))


all : {A : Set}{n : ℕ}(P : A → Set) → Vec A n → Set
all P []       = ⊤
all P (a ∷ as) = P a × all P as

all-lem₁ : {A : Set}{n : ℕ}(as : Vec A n) → ∀ P → all P as → (∀ a → a ∈ as → P a)
all-lem₁ []       P tt                    = λ a ()
all-lem₁ (a ∷ as) P (Pa , allas) .a  here = Pa
all-lem₁ (a ∷ as) P (Pa , allas)  a₁ (there a₁∈as) = all-lem₁ as P allas a₁ a₁∈as

all-lem₂ : {A : Set}{n : ℕ}(as : Vec A n) → ∀ P → (∀ a → P a) → all P as
all-lem₂ []       P ∀aPa = tt
all-lem₂ (a ∷ as) P ∀aPa = ∀aPa a , all-lem₂ as P ∀aPa


module Vec-Rep {A : Set}{n : ℕ}(dec : DecEq A)(It : Vec A (suc n))(∀a∈It : ∀ a → a ∈ It)(unique : Unique It) where

  Vec-any-lem₃ : ∀ P → Σ[ a ∈ A ] P a → any P It
  Vec-any-lem₃ P (a , Pa) = any-lem₂ It P (a , Pa , ∀a∈It a)

  Vec-any-lem₂ : ∀ P → any P It → Σ[ a ∈ A ] P a
  Vec-any-lem₂ P any = any-lem₁ It P any

  Vec-any-lem₁ : ∀ P → any P It ⇔ (Σ[ a ∈ A ] P a)
  Vec-any-lem₁ P = Vec-any-lem₂ P , Vec-any-lem₃ P

  Vec-any-lem₄ : ∀ P → ¬ (any P It) → ¬ (Σ[ a ∈ A ] P a)
  Vec-any-lem₄ P ¬any prf = ¬any (Vec-any-lem₃ P prf)

  Vec-all-lem₃ : ∀ P → (∀ a → P a) → all P It
  Vec-all-lem₃ P = all-lem₂ It P

  Vec-all-lem₂ : ∀ P → all P It → (∀ a → P a)
  Vec-all-lem₂ P all a = all-lem₁ It P all a (∀a∈It a)

  Vec-all-lem₁ : ∀ P → all P It ⇔ (∀ a → P a)
  Vec-all-lem₁ P = Vec-all-lem₂ P , Vec-all-lem₃ P

  Vec-all-lem₄ : ∀ P → ¬ (all P It) → ¬ (∀ a → P a)
  Vec-all-lem₄ P ¬allP ∀aPa = ¬allP (Vec-all-lem₃ P ∀aPa)

  It-lem₃ : {k j n : ℕ}(as : Vec A k)(bs : Vec A j)(cs : Vec A n)
            → (prf : k + j ≡ n)
            → cs ≡ subst (λ n → Vec A n) prf (as ++ bs)
            → ∀ a → a ∈ cs → a ∈ as ⊎ a ∈ bs
  It-lem₃ []      .cs cs refl refl  x x∈cs = inj₂ x∈cs
  It-lem₃ (a ∷ as) bs ._ refl refl .a here = inj₁ here
  It-lem₃ {suc k} {j} (a ∷ as) bs ._ refl refl  x (there x∈cs) with It-lem₃ {k} {j} as bs (as ++ bs) refl refl x x∈cs
  It-lem₃ {suc k} {j} (a ∷ as) bs ._ refl refl  x (there x∈cs) | inj₁ prf = inj₁ (there prf)
  It-lem₃ {suc k} {j} (a ∷ as) bs ._ refl refl  x (there x∈cs) | inj₂ prf = inj₂ prf

  It-lem₂ : {k j : ℕ}(as : Vec A k)(bs : Vec A (suc j))
            → (lenght-prf : k + suc j ≡ suc n)
            → It ≡ subst (λ n → Vec A n) lenght-prf (as ++ bs)
            → ∀ a → ¬ a ∈ as → a ≡ head bs ⊎ a ∈ tail bs
  It-lem₂ {k} {j} as bs prf It≡asbs a a∉as with It-lem₃ {k} {suc j} as bs It prf It≡asbs a (∀a∈It a)
  It-lem₂ as bs       prf It≡asbs  a a∉as | inj₁ a∈as = ⊥-elim (a∉as a∈as)
  It-lem₂ as (x ∷ bs) prf It≡asbs .x a∉as | inj₂ here = inj₁ refl
  It-lem₂ as (x ∷ bs) prf It≡asbs  a a∉as | inj₂ (there a∈bs) = inj₂ a∈bs

  It-lem₅ : {n : ℕ}(as : Vec A (suc n))
            → Unique as
            → ∀ a → a ∈ as → a ≡ head as → ¬ a ∈ tail as
  It-lem₅ (a ∷ [])     uni .a a∈as refl ()
  It-lem₅ (a ∷ x ∷ as) (a∉xas , uni-xas) .a a∈as refl a∈tail = ⊥-elim (a∉xas a∈tail)

  It-lem₇ : {n : ℕ}(as : Vec A (suc n))
            → ∀ a → a ∈ as → a ≡ head as ⊎ a ∈ tail as
  It-lem₇ (a ∷ []) .a here = inj₁ refl
  It-lem₇ (a ∷ []) b (there ())
  It-lem₇ (a ∷ x ∷ as) .a here = inj₁ refl
  It-lem₇ (a ∷ x ∷ as) b (there b∈as) = inj₂ b∈as

  It-lem₁ : ∀ a → a ≡ head It ⊎ a ∈ tail It
  It-lem₁ a = It-lem₂ [] It refl refl a (λ ())

  It-lem₄ : ∀ a → a ≢ head It → a ∈ tail It
  It-lem₄ a a≢head with It-lem₁ a
  It-lem₄ a a≢head | inj₁ a≡head = ⊥-elim (a≢head a≡head)
  It-lem₄ a a≢head | inj₂ a∈tail = a∈tail

  It-lem₆ : ∀ a → a ≡ head It → ¬ a ∈ tail It
  It-lem₆ a = It-lem₅ It unique a (∀a∈It a)

  It-lem₈ : {n : ℕ} → ∀ {b a} {as : Vec A n} → ¬ b ∈ a ∷ as → ¬ b ∈ as
  It-lem₈ ¬b∈aas b∈as = ¬b∈aas (there b∈as)

{-
  data Sub A : Set where
    keep : A → Sub A
    skip : A → Sub A

  DecEq-Sub : (a b : Sub A) → Dec (a ≡ b)
  DecEq-Sub (keep a) (keep  b) with dec a b
  DecEq-Sub (keep a) (keep .a) | yes refl = yes refl
  DecEq-Sub (keep a) (keep  b) | no  a≢b  = no (λ prf → a≢b (lem prf))
    where
      lem : {a b : A} → keep a ≡ keep b → a ≡ b
      lem refl = refl
  DecEq-Sub (keep a) (skip  b) = no (λ ())
  DecEq-Sub (skip a) (keep  b) = no (λ ())
  DecEq-Sub (skip a) (skip  b) with dec a b
  DecEq-Sub (skip a) (skip .a) | yes refl = yes refl
  DecEq-Sub (skip a) (skip  b) | no  a≢b  = no (λ prf → a≢b (lem prf))
    where
      lem : {a b : A} → skip a ≡ skip b → a ≡ b
      lem refl = refl
                   
  VecSubset : {n : ℕ} → Vec A n → Set
  VecSubset {n} _ = Vec (Sub A) n

  Ø : VecSubset It
  Ø = map skip It

  ⟦⟧-helper : {n : ℕ}(it : Vec A n) → A → VecSubset it
  ⟦⟧-helper []        a = []
  ⟦⟧-helper ( b ∷ bs) a with dec a b
  ⟦⟧-helper (.a ∷ bs) a | yes refl = keep a ∷ ⟦⟧-helper bs a
  ⟦⟧-helper ( b ∷ bs) a | no  a≢b  = skip b ∷ ⟦⟧-helper bs a

  ⟦_⟧ : A → VecSubset It
  ⟦ a ⟧ = ⟦⟧-helper It a

  DecEq-VSub : {n : ℕ}{it : Vec A n}(as bs : VecSubset it) → Dec (as ≡ bs)
  DecEq-VSub {.zero} {[]}     []       []         = yes refl
  DecEq-VSub {suc n} {x ∷ xs} (a ∷ as) ( b ∷  bs) with DecEq-Sub a b
  DecEq-VSub {suc n} {x ∷ xs} (a ∷ as) (.a ∷  bs) | yes refl with DecEq-VSub {n} {xs} as bs
  DecEq-VSub {suc n} {x ∷ xs} (a ∷ as) (.a ∷ .as) | yes refl | yes refl  = yes refl
  DecEq-VSub {suc n} {x ∷ xs} (a ∷ as) (.a ∷  bs) | yes refl | no  as≢bs = no  (aas≢abs {n} {xs} {a} {as} {bs} as≢bs)
    where
      aas≢abs : {n : ℕ}{it : Vec A n}{a : Sub A}{as bs : VecSubset it} → as ≢ bs → a ∷ as ≢ a ∷ bs
      aas≢abs as≢bs refl = as≢bs refl
  DecEq-VSub {suc n} {x ∷ xs} (a ∷ as) ( b ∷  bs) | no  a≢b  = no (aas≢abs {n} {xs} {a} {b} {as} {bs} a≢b)
    where
      aas≢abs : {n : ℕ}{it : Vec A n}{a b : Sub A}{as bs : VecSubset it} → a ≢ b → a ∷ as ≢ b ∷ bs
      aas≢abs a≢s refl = a≢s refl


  open import Subset.DecidableSubset renaming (Ø to Øᵈ ; _∈_ to _∈ᵈ_ ; _∈?_ to _∈ᵈ?_)

  VSub→DSub-lem₁ : {n : ℕ}{it : Vec A n} → VecSubset it → DecSubset A
  VSub→DSub-lem₁ [] = Øᵈ
  VSub→DSub-lem₁ (keep a ∷ as)  b with dec a b
  VSub→DSub-lem₁ (keep a ∷ as) .a | yes refl = true
  VSub→DSub-lem₁ (keep a ∷ as)  b | no  _    = false
  VSub→DSub-lem₁ (skip a ∷ as)  b = false

  DSub→VSub-lem₁ : {n : ℕ} → (it : Vec A n) → DecSubset A → VecSubset it
  DSub→VSub-lem₁ []       bs = []
  DSub→VSub-lem₁ (a ∷ as) bs with a ∈ᵈ? bs
  DSub→VSub-lem₁ (a ∷ as) bs | true  = keep a ∷ DSub→VSub-lem₁ as bs
  DSub→VSub-lem₁ (a ∷ as) bs | false = skip a ∷ DSub→VSub-lem₁ as bs

  DSub→VSub : DecSubset A → VecSubset It
  DSub→VSub as = DSub→VSub-lem₁ It as

  VSub→DSub : VecSubset It → DecSubset A
  VSub→DSub as = VSub→DSub-lem₁ {it = It} as

  VSub⇔DSub : VecSubset It ⇔ DecSubset A
  VSub⇔DSub = VSub→DSub , DSub→VSub
-}
