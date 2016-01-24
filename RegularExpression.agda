{-
  Here the Regular Expressions and the language denoted by them are 
  defined according to:
    The Theory of Parsing, Translation and Compiling (Vol. 1 : Parsing)
    Section 2.2: Regular sets, their generators, and their recognizers
      by Alfred V. Aho and Jeffery D. Ullman

  Steven Cheung 2015.
  Version 07-01-2016
-}

module RegularExpression (Σ : Set) where

open import Data.Product hiding (Σ)

open import Language Σ renaming (Ø to ø)
open import Subset using (_≈_)


-- Regular expressions
-- section 2.2.1: Regular Sets and Regular Expressions
infix 11 _∣_
infix 12 _∙_
infix 13 _*
data RegExp : Set where
  Ø   : RegExp 
  ε   : RegExp 
  σ   : Σ → RegExp
  _∣_ : RegExp → RegExp → RegExp
  _∙_ : RegExp → RegExp → RegExp
  _*  : RegExp → RegExp


-- Language denoted by regular expressions
-- section 2.2.1: Regular Sets and Regular Expressions
Lᴿ : RegExp → Language
Lᴿ Ø         = ø
Lᴿ ε         = ⟦ε⟧
Lᴿ (σ a)     = ⟦ a ⟧
Lᴿ (e₁ ∣ e₂) = Lᴿ e₁ ⋃ Lᴿ e₂
Lᴿ (e₁ ∙ e₂) = Lᴿ e₁ • Lᴿ e₂
Lᴿ (e *)     = (Lᴿ e) ⋆


-- Regular Language is the language that can be denoted by a Regular Expression
Regular : Language → Set
Regular L = Σ[ e ∈ RegExp ] (L ≈ Lᴿ e)
