{-
  This module contains the following proofs:
    ∀e∈RegExp. L(e) ⊆ L(regexToε-NFA e)
    ∀e∈RegExp. L(e) ⊇ L(regexToε-NFA e)

  Steven Cheung 2015.
  Version 10-12-2015
-}
open import Util
module Correctness.RegExpToe-NFA (Σ : Set)(dec : DecEq Σ) where

open import Data.List
open import Data.Bool
open import Relation.Binary.PropositionalEquality
open import Relation.Nullary
open import Data.Sum
open import Data.Product hiding (Σ)
open import Data.Unit
open import Data.Empty
open import Data.Nat

open import Subset renaming (Ø to ø)
open import Subset.DecidableSubset renaming (Ø to ø ; _∈_ to _∈ᵈ_)
open import Language Σ
open import RegularExpression Σ
open import Automata Σ
open import Translation Σ dec
open import State


{- ∀e∈RegExp. L(e) ⊆ L(regexToε-NFA e) -}
Lᴿ⊆Lᵉᴺ : ∀ e → Lᴿ e ⊆ Lᵉᴺ (regexToε-NFA e)
-- null
Lᴿ⊆Lᵉᴺ Ø _ ()
-- ε
Lᴿ⊆Lᵉᴺ ε []       refl = init , refl , 0 , refl , refl
Lᴿ⊆Lᵉᴺ ε (x ∷ xs) ()
-- singleton
Lᴿ⊆Lᵉᴺ (σ a) w w∈Lᴿ = lem₁ w w∈Lᴿ
 where open import Correctness.RegExpToe-NFA.Singleton-lemmas Σ dec a
-- union
Lᴿ⊆Lᵉᴺ (e₁ ∣ e₂) w (inj₁ w∈Lᴿ) = lem₁ (Lᴿ⊆Lᵉᴺ e₁ w w∈Lᴿ)
 where open import Correctness.RegExpToe-NFA.Union-lemmas Σ dec e₁ e₂
Lᴿ⊆Lᵉᴺ (e₁ ∣ e₂) w (inj₂ w∈Lᴿ) = lem₄ (Lᴿ⊆Lᵉᴺ e₂ w w∈Lᴿ)
 where open import Correctness.RegExpToe-NFA.Union-lemmas Σ dec e₁ e₂
-- concatenation
Lᴿ⊆Lᵉᴺ (e₁ ∙ e₂) w (u , v , u∈Lᴿe₁ , v∈Lᴿe₂ , w≡uv)
  = lem₁ w≡uv (Lᴿ⊆Lᵉᴺ e₁ u u∈Lᴿe₁) (Lᴿ⊆Lᵉᴺ e₂ v v∈Lᴿe₂)
 where open import Correctness.RegExpToe-NFA.Concatenation-lemmas Σ dec e₁ e₂
-- kleen star
Lᴿ⊆Lᵉᴺ (e * ) .[] (zero , refl) = init , refl , 0 , refl , refl  
Lᴿ⊆Lᵉᴺ (e * )  w  (suc n , u , v , u∈Lᴿe , v∈Lᴿeⁿ⁺¹ , w≡uv)
  = lem n w u v w≡uv (Lᴿ⊆Lᵉᴺ e u u∈Lᴿe) v∈Lᴿeⁿ⁺¹
 where
  open import Correctness.RegExpToe-NFA.KleenStar-lemmas Σ dec e
  open ε-NFA nfa
  open ε-NFA nfa₁ renaming (Q to Q₁ ; Q? to Q₁? ; δ to δ₁ ; q₀ to q₀₁ ; F to F₁)
  open ε-NFA-Operations nfa
  lem : ∀ n w u v
       → w ≡ u ++ v
       → u ∈ Lᵉᴺ nfa₁
       → v ∈ (Lᴿ e ^ n)
       → w ∈ Lᵉᴺ nfa
  lem zero    w u .[] w≡u[] u∈Lᴺ refl
    = lem₁ w u w≡u[] u∈Lᴺ
  lem (suc n) w u  v  w≡uv  (q , q∈F₁ , (n₁ , prf₁)) (s , t , s∈Lᴿe , t∈Lᴿeⁿ , v≡st) with lem n v s t v≡st (Lᴿ⊆Lᵉᴺ e s s∈Lᴿe) t∈Lᴿeⁿ
  lem (suc n) w u  v  w≡uv  (q , q∈F₁ , (n₁ , prf₁)) (s , t , s∈Lᴿe , t∈Lᴿeⁿ , v≡st) | (.init , refl , (zero , (refl , v≡[])))
    = lem₁ w u (subst (λ v → w ≡ u ++ v) (Σᵉ*-lem₂ v≡[]) w≡uv) (q , q∈F₁ , (n₁ , prf₁))
  lem (suc n) w u  v  w≡uv  (q , q∈F₁ , (n₁ , prf₁)) (s , t , s∈Lᴿe , t∈Lᴿeⁿ , v≡st) | (q₂ , q₂∈F , (suc n₂ , prf₂)) with inj q₀₁ ∈ᵈ δ (inj q) E | inspect (δ (inj q) E) (inj q₀₁)
  lem (suc n) w u  v  w≡uv  (q , q∈F₁ , (n₁ , prf₁)) (s , t , s∈Lᴿe , t∈Lᴿeⁿ , v≡st) | (q₂ , q₂∈F , (suc n₂ , prf₂)) | true  | [ eq ]
    = q₂ , q₂∈F , ⊢*-lem₁ (suc n₁ , suc n₂ , inj q , (toΣᵉ* v)
         , lem₅ (toΣᵉ* w) n₁ q (toΣᵉ* u) (toΣᵉ* v) (Σᵉ*-lem₁ {w} {u} {v} w≡uv) prf₁
         , (inj q₀₁ , E , (toΣᵉ* v) , inj₂ (refl , refl) , (refl , eq) , lem₇ (toΣᵉ* v) prf₂))
   where
    lem₇ : ∀ v
           → (init , v) ⊢ᵏ suc n₂ ─ (q₂ , [])
           → (inj q₀₁ , v) ⊢ᵏ n₂ ─ (q₂ , [])
    lem₇ v (init  , E     , v' , _                  , (refl , ())          , pv'⊢ᵏq₂[])
    lem₇ v (init  , (α a) , v' , _                  , (refl , ())          , pv'⊢ᵏq₂[])
    lem₇ v (inj p , .E    , .v , inj₂ (refl , refl) , (refl , injp∈δinitE) , pv'⊢ᵏq₂[]) with Q₁? p q₀₁
    lem₇ v (inj p , .E    , .v , inj₂ (refl , refl) , (refl , injp∈δinitE) , pv'⊢ᵏq₂[]) | yes p≡q₀₁ = subst (λ p → (inj p , v) ⊢ᵏ n₂ ─ (q₂ , [])) p≡q₀₁ pv'⊢ᵏq₂[]
    lem₇ v (inj p , .E    , .v , inj₂ (refl , refl) , (refl , ()         ) , pv'⊢ᵏq₂[]) | no  p≢q₀₁
    lem₇ v (inj p , (α a) , v' , inj₁ (v₁≡v' , ā≢E) , (refl , ())          , pv'⊢ᵏq₂[])
    lem₇ v (inj p , E     , v' , inj₁ (v₁≡v' , a≢E) , (refl , _)           , pv'⊢ᵏq₂[]) = ⊥-elim (a≢E refl)
  lem (suc n) w u  v  w≡uv  (q , q∈F₁ , (n₁ , prf₁)) (s , t , s∈Lᴿe , t∈Lᴿeⁿ , v≡st) | (q₂ , q₂∈F , (suc n₂ , prf₂)) | false | [ eq ] with q ∈ᵈ F₁ | Q₁? q₀₁ q₀₁
  lem (suc n) w u  v  w≡uv  (q , q∈F₁ , (n₁ , prf₁)) (s , t , s∈Lᴿe , t∈Lᴿeⁿ , v≡st) | (q₂ , q₂∈F , (suc n₂ , prf₂)) | false | [ () ] | true  | yes refl    
  lem (suc n) w u  v  w≡uv  (q , ()   , (n₁ , prf₁)) (s , t , s∈Lᴿe , t∈Lᴿeⁿ , v≡st) | (q₂ , q₂∈F , (suc n₂ , prf₂)) | false | [ eq ] | false | yes refl
  lem (suc n) w u  v  w≡uv  (q , q∈F₁ , (n₁ , prf₁)) (s , t , s∈Lᴿe , t∈Lᴿeⁿ , v≡st) | (q₂ , q₂∈F , (suc n₂ , prf₂)) | false | [ eq ] | _     | no  q₀₁≢q₀₁ = ⊥-elim (q₀₁≢q₀₁ refl)

{- ∀e∈RegExp. L(e) ⊇ L(regexToε-NFA e) -}
Lᴿ⊇Lᵉᴺ : ∀ e → Lᴿ e ⊇ Lᵉᴺ (regexToε-NFA e)
{-
-- null
Lᴿ⊇Lᵉᴺ Ø w  (_ , () , _)
-- ε
Lᴿ⊇Lᵉᴺ ε [] _ = refl
Lᴿ⊇Lᵉᴺ ε (x ∷ xs) (init  , tt , zero  , _ , ())
Lᴿ⊇Lᵉᴺ ε (x ∷ xs) (init  , tt , suc n , init  , E   , w         , inj₁ (() , _) , (refl , tt) ,  initw⊢ᵏinit[])
Lᴿ⊇Lᵉᴺ ε (x ∷ xs) (init  , tt , suc n , init  , E   , []        , inj₂ (() , _) , (refl , tt) ,  initw⊢ᵏinit[])
Lᴿ⊇Lᵉᴺ ε (x ∷ xs) (init  , tt , suc n , init  , E   , (E ∷ w)   , inj₂ (() , _) , (refl , tt) ,  initw⊢ᵏinit[])
Lᴿ⊇Lᵉᴺ ε (x ∷ xs) (init  , tt , suc n , init  , E   , (α a ∷ w) , _             , (refl , tt) ,  initw⊢ᵏinit[])
  = ⊥-elim (lem₁ a w n initw⊢ᵏinit[])
 where
  open import Correctness2.RegExpToe-NFA.Epsilon-lemmas Σ
Lᴿ⊇Lᵉᴺ ε (x ∷ xs) (init  , tt , suc n , init  , α a , w         , _             , (refl , ()) ,  initw⊢ᵏinit[]) 
Lᴿ⊇Lᵉᴺ ε (x ∷ xs) (init  , tt , suc n , error , E   , w         , _             , (refl , ()) , errorw⊢ᵏinit[])
Lᴿ⊇Lᵉᴺ ε (x ∷ xs) (init  , tt , suc n , error , α a , w         , _             , (refl , tt) , errorw⊢ᵏinit[])
  = ⊥-elim (lem₂ w n [] errorw⊢ᵏinit[])
 where
  open import Correctness2.RegExpToe-NFA.Epsilon-lemmas Σ
Lᴿ⊇Lᵉᴺ ε (x ∷ xs) (error , () , _)
-- singleton
Lᴿ⊇Lᵉᴺ (σ a) [] (init   , () , _)
Lᴿ⊇Lᵉᴺ (σ a) [] (accept , tt , zero , () , _)
Lᴿ⊇Lᵉᴺ (σ a) [] (accept , tt , suc n , q      , E   , w , inj₁ (() , _) , _           , _)
Lᴿ⊇Lᵉᴺ (σ a) [] (accept , tt , suc n , init   , E   , w , _             , (refl , tt) , _) = undefined
Lᴿ⊇Lᵉᴺ (σ a) [] (accept , tt , suc n , accept , E   , w , _             , (refl , ()) , _)
Lᴿ⊇Lᵉᴺ (σ a) [] (accept , tt , suc n , error  , E   , w , _             , (refl , ()) , _)
Lᴿ⊇Lᵉᴺ (σ a) [] (accept , tt , suc n , q      , α b , w , inj₁ (() , _) , _           , _)
Lᴿ⊇Lᵉᴺ (σ a) [] (accept , tt , suc n , q      , α b , w , inj₂ (_ , ()) , _           , _)
Lᴿ⊇Lᵉᴺ (σ a) [] (error  , () , _)
Lᴿ⊇Lᵉᴺ (σ a) (.a ∷ []) (accept , tt , 1 , accept , α .a , [] , inj₁ (refl , prf) , (refl , refl) , refl , refl) = refl
Lᴿ⊇Lᵉᴺ (σ a) ( x ∷ [])     _ = undefined
Lᴿ⊇Lᵉᴺ (σ a) ( x ∷ y ∷ xs) _ = undefined
-}
-- others
Lᴿ⊇Lᵉᴺ _ = undefined
