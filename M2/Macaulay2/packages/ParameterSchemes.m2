newPackage(
	"ParameterSchemes",
    	Version => "0.01", 
    	Date => "February 21, 2008",
    	Authors => {{Name => "Mike Stillman", 
		  Email => "mike@math.cornell.edu", 
		  HomePage => "http://www.math.cornell.edu/~mike/"}},
    	Headline => "a Macaulay 2 package for local equations of Hilbert and other parameter schemes",
    	DebuggingMode => true
    	)

export { smallerMonomials, standardMonomials, parameterFamily, parameterIdeal, pruneParameterScheme }
-- This will be based on the code which occurs here and there on my disk, including "localhilb.m2"
-- Perhaps there are more recent places??  This is one reason I am writing this package, to put it
-- in one place!

-- WARNING: this package is not yet written!!  We should first (perhaps) make sure that minimalPresentation
-- of a ring is rock solid, although this package can easily be used to produce interesting test cases 
-- for that.

smallerMonomials = method()
smallerMonomials(Ideal,RingElement) := (M,f) -> (
     -- input: a polynomial in a poly ring R
     -- output: an ordered list of monomials of R less than f, but of the same
     --   degree as (the leadterm of) f.
     d := degree f;
     m := flatten entries basis(d,coker gens M);
     m = f + sum m;
     b := apply(listForm m, t -> R_(first t));
     x := position(b, g -> g == f);
     drop(b,x+1))

smallerMonomials(Ideal,RingElement,ZZ) := (M,f,dummy) -> (
     -- input: a polynomial in a poly ring R
     -- output: an ordered list of monomials of R less than f, but of the same
     --   degree as (the leadterm of) f.
     d := degree f;
     m := flatten entries basis(d,coker gens M);
     select(m, m0 -> m0 < f))

smallerMonomials(Ideal) := (M) -> (
     Mlist := flatten entries gens M;
     apply(Mlist, m -> smallerMonomials(M,m)))

smallerMonomials(List) := (L) -> (
     M := ideal L;
     apply(L, m -> smallerMonomials(M,m)))

standardMonomials = method()
standardMonomials(ZZ,Ideal) :=
standardMonomials(List,Ideal) := (d,M) -> (
     (terms sum flatten entries basis(d,comodule M))/leadMonomial
     )

standardMonomials(Ideal) := (I) -> (
     L := flatten entries generators I;
     apply(L, f -> standardMonomials(degree f, I))
     )
standardMonomials(List) := (L) -> (
     I := ideal L;
     apply(L, f -> standardMonomials(degree f, I))
     )

parameterFamily = method()
parameterFamily(Ideal,List,Symbol) := (M,L,t) -> (
     -- M is a monomial ideal
     -- L is a list of lists of monomials, #L is the
     --  number of generators of M.
     R := ring M;
     kk := coefficientRing R;
     nv := sum apply(L, s -> #s);
     R1 := kk[t_1..t_nv];
     U := R1 (monoid R);
     --U := tensor(R,R1,DegreeRank=>1);  
     lastv := -1;
     Mlist := flatten entries gens M;
     elems := apply(#Mlist, i -> (
	       m := Mlist_i;
	       substitute(m,U) + sum apply(L#i, p -> (
			 lastv = lastv + 1;
			 R1_lastv * substitute(p,U)))));
     ideal elems
     )

parameterIdeal = method()
parameterIdeal(Ideal,Ideal) := (M,family) -> (
     -- M is a monomial ideal in a polynomial ring
     -- family is the result of a call to 'parameterFamily'
     R := ring M;
     time G = forceGB gens family;
     time syzM = substitute(syz gens M, ring family);
     time eq = compress((gens family * syzM) % G);
     --time (mons,eqns) := toSequence coefficients(toList(0..(numgens R)-1), eq);
     time (mons,eqns) = coefficients(eq); -- , Variables=>apply(gens R, x -> substitute(x,ring eq)));
     ideal lift(eqns,coefficientRing ring eqns))

pruneParameterScheme = method()
pruneParameterScheme(Ideal,Ideal) := (J,F) -> (
     R := ring F;
     A := coefficientRing R;
     if ring J =!= A then error "expected(ideal in coeffring A, family in A[x])";
     J1 := minimalPresentation J;
     B := ring J1;
     phi := J.cache.minimalPresentationMap; -- map: A --> B
     -- want the induced map from A[x] -> B[x]
     S := B (monoid R);
     phi' := map(S,R,vars S | substitute(phi.matrix,S));
     (J1, phi' F)
     )

beginDocumentation()
document { 
	Key => ParameterSchemes,
	Headline => "a Macaulay 2 package for local equations of Hilbert and other parameter schemes",
	EM "ParameterSchemes", " is a package containing tools to create parameter schemes, 
	  especially about a monomial ideal."
	}

{* document {
	Key => {(firstFunction,ZZ),firstFunction},
	Headline => "a silly first function",
	Usage => "firstFunction n",
	Inputs => { "n" },
	Outputs => {{ "a silly string, depending on the value of ", TT "n" }},
        SourceCode => {(firstFunction,ZZ)},
	EXAMPLE lines ///
	   firstFunction 1
	   firstFunction 0
     	///
	}
*}
TEST ///
    assert ( firstFunction 2 == "D'oh!" )
///


end
restart
loadPackage "ParameterSchemes"
R = ZZ/101[a..e,MonomialOrder=>Lex]
R = ZZ/101[a..f]
I = ideal"ab,bc,cd,de,ea,ac"
R = ZZ/101[a..g]
I = ideal"ab,bc,cd,de,ea,ac"

R = ZZ/101[a..e,MonomialOrder=>Lex]
I = ideal"ab,bc,cd,ad"
L1 = smallerMonomials I
F0 = parameterFamily(I,L1,symbol t)
J0 = parameterIdeal(I,F0)
(J,F) = pruneParameterScheme(J0,F0)
B = ring J
rand = map(R,ring F,(vars R) | random(R^1, R^(numgens B)))
L = rand F
primaryDecomposition L
primaryDecomposition I

R = ZZ/101[a..e]
I = ideal"ab,bc,cd,ad"
L1 = smallerMonomials I
F0 = parameterFamily(I,L1,symbol t)
J0 = parameterIdeal(I,F0)
(J,F) = pruneParameterScheme(J0,F0)
B = ring J
rand = map(R,ring F,(vars R) | random(R^1, R^(numgens B)))
L = rand F
primaryDecomposition L
primaryDecomposition I

R = ZZ/101[a..f]
I = ideal"ab,bc,cd,de,ea,ad"
L1 = smallerMonomials I
F0 = parameterFamily(I,L1,symbol t)
J0 = parameterIdeal(I,F0);
time (J,F) = pruneParameterScheme(J0,F0);
B = ring J
rand = map(R,ring F,(vars R) | random(R^1, R^(numgens B)))
L = rand F
decompose J
intersect oo == J -- yes
primaryDecomposition L
primaryDecomposition I

R = ZZ/101[a..f,MonomialOrder=>Lex]
I = ideal"ab,bc,cd,ad,de"
L1 = smallerMonomials I
F0 = parameterFamily(I,L1,symbol t)
S = ring F1
J0 = parameterIdeal(I,F0)
(J,F) = pruneParameterScheme(J0,F0)

time minimalPresentation J
substitute(J.cache.minimalPresentationMap F1,S)
see oo

T = ZZ/101[gens ring J]
JT = substitute(J,T)
gens gb JT;
debug ParameterSchemes
B = flatten entries ((gens F1) * syzM)
B_0 % G
B_1 % G
H = flatten entries gens G
netList H
netList B
B_1 - e*t_18*H_1 +c*t_13*H_0 - d*t_13*t_19*H_0 + e*t_14*H_0 - e*t_13*t_20*H_0
B_1 % G

matrix{{B_1}} % G

A = (ZZ/101){t_1..t_30}
S = A[gens R]
smallerMonomials flatten entries gens I
L2 = standardMonomials I
F1 = parameterFamily(I,L1,symbol t)
S = ring F1
J = parameterIdeal(I,F1)
T = ZZ/101[gens ring J]
J = substitute(J,T)
gens gb J;
K = ideal select(flatten entries oo, f -> first degree f > 1)
minimalPresentation K
decompose oo
gens gb K
decompose K
(gens substitute(F1,T)) % J
ideal((gens F1) % (trim parameterIdeal(I,F1)))
compress gens oo
R = ZZ/101[a..e, MonomialOrder=>Lex]
I = ideal"ab,bc,cd,ad"
smallerMonomials I
smallerMonomials flatten entries gens I
standardMonomials I

-- For local equations
-- Compute the parameter equations

getStandardMonomials = (M,d) -> (
     -- input: monomial ideal M
     --        integer d
     -- outut: list of standard monomials of M of degree d, in order
     R := ring M;
     m := sum flatten entries basis(d,coker gens M);
     apply(listForm m, t -> R_(first t)))

getStds = (M) -> (
     Mlist := flatten entries gens M;
     apply(Mlist, m -> getStandardMonomials(M,degree m)))

familyIdeal = (M,stds,t) -> (
     R := ring M;
     nv := sum apply(stds, s -> #s);
     R1 := (coefficientRing R)[t_1..t_nv,
	                       MonomialOrder=>{Weights=>nv:-1,GRevLex=>nv}, Global=>false];
     U := R1 ** R;  
     lastv := -1;
     elems := apply(numgens M, i -> (
	       m := M_i;
	       substitute(m,U) + sum apply(stds#i, p -> (
			 lastv = lastv + 1;
			 U_lastv * substitute(p, U)))));
     ideal elems
     )

parameterIdeal = (M,family) -> (
     -- M is a monomial ideal in a polynomial ring
     -- family is the result of 'familyIdeal'
     R := ring M;
     time G := forceGB gens family;
     time syzM := substitute(syz gens M, ring family);
     time eq := compress((gens family * syzM) % G);
     --time (mons,eqns) := toSequence coefficients(toList(0..(numgens R)-1), eq);
     time (mons,eqns) := coefficients(eq, Variables=>apply(gens R, x -> substitute(x,ring eq)));
     ideal eqns)

localEquations = method()
localEquations(Ideal,Symbol) := (I,x) -> (
     -- Assume: I is a monomial ideal
     -- put all of the above together
     family := familyIdeal(I, getStds I, t);
     U := ring family;
     oldvars := toList(numgens U - numgens ring I .. numgens U - 1);
     print oldvars;
     G := forceGB gens family;
     syzI = substitute(syz gens I, U);
     eqs = (gens family) * syzI;
     eqs1 = eqs % G;
     eqs2 = compress eqs1;
     (ms,cs) = coefficients(eqs2, Variables=>apply(oldvars, i -> (ring eqs2)_i));
     (ideal compress matrix {flatten entries cs}, family)
     )

end
restart
path = prepend("/Users/mike/Macaulay2/code/",path)
load "localhilb.m2"
R = ZZ/32003[a..c]
I = ideal(a^2,a*b^2)
(J,fam) = localEquations(I,symbol t)
transpose gens gb J


R = ZZ/32003[a..d]
(J,fam) = localEquations(ideal(a*b, a*c, b^3), symbol t)
gbTrace = 3
gens gb J;
G = forceGB gens fam
syzI
eqs


F = J_(0,0)
F % G
g1 = fam_0 -- lead term a*b
g2 = fam_1 -- lead term a*c
g3 = fam_2 -- lead term b^3
F
use ring F
F + t_1 * a * g2 + t_5* d * g2 - t_9*a*g1 -t_10*g3 -t_13*d*g1 - t_2*t_9*b*g1
gens gb J


getStandardMonomials(I,3)
getStds I


family = familyIdeal(I,getStds I,t)
U = ring family
time G = forceGB gens family;
time syzI = substitute(syz gens I, ring family);
eqs = ((gens family) * syzI)
eqs1 = eqs % G
eqs2 = compress eqs1
coefficients({a,b,c},eqs2)
J = ideal oo_1
gbTrace = 3
gens gb J;
transpose gens gb J
R = ZZ/32003[s,t_1..t_11,MonomialOrder=>Eliminate 1]
J = ideal(t_2-t_1*t_6+t_6^2,
     t_4-t_3*t_6+t_2*t_7-t_1*t_8+2*t_6*t_8-t_6^2*t_7,
     -t_10+t_7*t_8+t_6*t_9-t_6*t_7^2,
     t_5+t_4*t_7-t_3*t_8+t_8^2+t_2*t_9-t_1*t_10+t_6*t_10-t_6*t_7*t_8,
     -t_11+t_8*t_9-t_6*t_7*t_9,
     t_5*t_7+t_4*t_9-t_3*t_10+t_8*t_10-t_1*t_11+t_6*t_11-t_6*t_7*t_10,
     t_5*t_9-t_3*t_11+t_8*t_11-t_6*t_7*t_11)
J = homogenize(J,s)
gens gb J
transpose gens gb J
mingens ideal substitute(leadTerm gens gb J, {s=>1})

-- example: initial ideal is an edge ideal
restart
path = prepend("/Users/mike/Macaulay2/code/",path)
load "localhilb.m2"
R = ZZ/32003[a..f]
I = ideal"ab,bc,cd,de,ea"
(J,fam) = localEquations(I,symbol t)
transpose gens gb J
