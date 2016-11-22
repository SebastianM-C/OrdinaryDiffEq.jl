using OrdinaryDiffEq, DiffEqDevTools

const linear_bigα = parse(BigFloat,"1.01")
f = (t,u) -> (linear_bigα*u)
analytic = (t,u0) -> u0*exp(linear_bigα*t)
prob_ode_bigfloatlinear = ODETestProblem(f,parse(BigFloat,"0.5"),analytic,(0.0,10.0))

f = (t,u,du) -> begin
  for i in 1:length(u)
    du[i] = linear_bigα*u[i]
  end
end
prob_ode_bigfloat2Dlinear = ODETestProblem(f,map(BigFloat,rand(4,2)).*ones(4,2)/2,analytic,(0.0,10.0))

linear = (t,u) -> (1.01*u)
analytic_linear = (t,u0) -> u0*exp(1.01*t)
probnum = ODETestProblem(linear,1/2,analytic_linear,(0.0,10.0))

probnumbig = prob_ode_bigfloatlinear
#prob    = prob_ode_large2Dlinear


f_2dlinear = (t,u,du) -> begin
  for i in 1:length(u)
    du[i] = 1.01*u[i]
  end
end
analytic_2dlinear = (t,u0) -> u0*exp.(1.01*t)
prob = ODETestProblem(f_2dlinear,rand(4,2),analytic_2dlinear,(0.0,10.0))

probbig = prob_ode_bigfloat2Dlinear
dts = 1.//2.^(7:-1:4)
testTol = .2
bools = Vector{Bool}(0)

## DP5()

sim = test_convergence(dts,probnum,DP5())
@test abs(sim.𝒪est[:l2]-5) < testTol
sim = test_convergence(dts,prob,DP5())
@test abs(sim.𝒪est[:l2]-5) < testTol

sol1 =solve(probnum,DP5(),dt=1/2^6,adaptive=false,save_timeseries=false)
sol2 =solve(probnum,ExplicitRK(),dt=1/2^6,adaptive=false,save_timeseries=false)

@test sol1.u[end] - sol2.u[end] < 1e-10

sol1 =solve(prob,DP5(),dt=1/2^6,adaptive=false,save_timeseries=false)
sol2 =solve(prob,ExplicitRK(),dt=1/2^6,adaptive=false,save_timeseries=false)

@test minimum(sol1.u[end] - sol2.u[end] .< 3e-10)

sol1 =solve(probnum,DP5(),dt=1/2^6,beta2=0.04)
sol2 =solve(probnum,ExplicitRK(),dt=1/2^6,beta2=0.04)


# Should be identical
sol1 =solve(prob,DP5())
sol2 =solve(prob,ExplicitRK(),beta2=0.04,beta1=0.17)
sol3 =solve(prob,dopri5())

@test length(sol1) == length(sol2) == length(sol3)

### BS3()
sim = test_convergence(dts,probnum,BS3())
@test abs(sim.𝒪est[:l2]-3) < testTol
sim = test_convergence(dts,prob,BS3())
@test abs(sim.𝒪est[:l2]-3) < testTol

tab = constructBogakiShampine3()
sol1 =solve(probnum,BS3(),dt=1/2^1,adaptive=false,save_timeseries=false)
sol2 =solve(probnum,ExplicitRK(),dt=1/2^1,adaptive=false,save_timeseries=false, tableau=tab)

@test sol1.u[end] - sol2.u[end] < 1e-10

sol1 =solve(prob,BS3(),dt=1/2^1,adaptive=false,save_timeseries=false)
sol2 =solve(prob,ExplicitRK(),dt=1/2^1,adaptive=false,save_timeseries=false, tableau=tab)

@test minimum(sol1.u[end] - sol2.u[end] .< 1e-10)

sol1 =solve(prob,ExplicitRK(),dt=1/2^6,tableau=tab)
sol2 =solve(prob,BS3(),dt=1/2^6)

@test length(sol1) == length(sol2)

### BS5()
dts = 1.//2.^(6:-1:3)
sim = test_convergence(dts,probnumbig,BS5())
@test abs(sim.𝒪est[:l2]-5) < testTol
sim = test_convergence(dts,probbig,BS5())
@test abs(sim.𝒪est[:l2]-5) < testTol

tab = constructBogakiShampine5()
sol1 =solve(probnum,BS5(),dt=1/2^6,adaptive=false,save_timeseries=false)
sol2 =solve(probnum,ExplicitRK(),dt=1/2^6,adaptive=false,save_timeseries=false, tableau=tab)

@test sol1.u[end] - sol2.u[end] < 1e-10

sol1 =solve(prob,BS5(),dt=1/2^3,adaptive=false,save_timeseries=false)
sol2 =solve(prob,ExplicitRK(),dt=1/2^3,adaptive=false,save_timeseries=false, tableau=tab)

@test minimum(sol1.u[end] - sol2.u[end] .< 1e-10)

sol1 =solve(prob,ExplicitRK(),dt=1/2^6,tableau=tab)
sol2 =solve(prob,BS5(),dt=1/2^6)

@test length(sol1) <= length(sol2) # Dual error estimators is more strict

### Tsit5()

dts = 1.//2.^(7:-1:3)
sim = test_convergence(dts,probnum,Tsit5())
@test abs(sim.𝒪est[:l2]-5) < testTol+.1
sim = test_convergence(dts,prob,Tsit5())
@test abs(sim.𝒪est[:l2]-5) < testTol+.1

tab = constructTsitouras5()
sol1 =solve(probnum,Tsit5(),dt=1/2^6,adaptive=false,save_timeseries=false)
sol2 =solve(probnum,ExplicitRK(),dt=1/2^6,adaptive=false,save_timeseries=false, tableau=tab)

@test sol1.u[end] - sol2.u[end] < 1e-10

sol1 =solve(prob,Tsit5(),dt=1/2^3,adaptive=false,save_timeseries=false)
sol2 =solve(prob,ExplicitRK(),dt=1/2^3,adaptive=false,save_timeseries=false, tableau=tab)

@test minimum(sol1.u[end] - sol2.u[end] .< 1e-10)

sol1 =solve(prob,ExplicitRK(),dt=1/2^6,tableau=tab)
sol2 =solve(prob,Tsit5(),dt=1/2^6)

@test length(sol1) == length(sol2)

### Vern6()

dts = 1.//2.^(8:-1:5)
sim = test_convergence(dts,probnumbig,Vern6())
@test abs(sim.𝒪est[:l2]-6) < testTol
sim = test_convergence(dts,probbig,Vern6())
@test abs(sim.𝒪est[:l2]-6) < testTol

tab = constructVernerEfficient6(BigFloat)
sol1 =solve(probnumbig,Vern6(),dt=1/2^6,adaptive=false,save_timeseries=false)
sol2 =solve(probnumbig,ExplicitRK(),dt=1/2^6,adaptive=false,save_timeseries=false, tableau=tab)

@test sol1.u[end] - sol2.u[end] < 1e-10

sol1 =solve(probbig,Vern6(),dt=1/2^3,adaptive=false,save_timeseries=false)
sol2 =solve(probbig,ExplicitRK(),dt=1/2^3,adaptive=false,save_timeseries=false, tableau=tab)

@test minimum(sol1.u[end] - sol2.u[end] .< 1e-10)

sol1 =solve(probbig,ExplicitRK(),dt=1/2^6,tableau=tab)
sol2 =solve(probbig,Vern6(),dt=1/2^6)

@test length(sol1) == length(sol2)

### Vern7()

dts = 1.//2.^(6:-1:3)
sim = test_convergence(dts,probnumbig,Vern7())
@test abs(sim.𝒪est[:l2]-7) < testTol
sim = test_convergence(dts,probbig,Vern7())
@test abs(sim.𝒪est[:l2]-7) < testTol

tab = constructVerner7(BigFloat)
sol1 =solve(probnumbig,Vern7(),dt=1/2^6,adaptive=false,save_timeseries=false)
sol2 =solve(probnumbig,ExplicitRK(),dt=1/2^6,adaptive=false,save_timeseries=false, tableau=tab)

@test sol1.u[end] - sol2.u[end] < 1e-10

sol1 =solve(probbig,Vern7(),dt=1/2^3,adaptive=false,save_timeseries=false)
sol2 =solve(probbig,ExplicitRK(),dt=1/2^3,adaptive=false,save_timeseries=false, tableau=tab)

@test minimum(sol1.u[end] - sol2.u[end] .< 1e-10)

sol1 =solve(probbig,ExplicitRK(),dt=1/2^6,tableau=tab)
sol2 =solve(probbig,Vern7(),dt=1/2^6)

@test length(sol1) == length(sol2)

### TanYam7()

dts = 1.//2.^(6:-1:3)
sim = test_convergence(dts,probnumbig,TanYam7())
@test abs(sim.𝒪est[:l2]-7) < testTol
sim = test_convergence(dts,probbig,TanYam7())
@test abs(sim.𝒪est[:l2]-7) < testTol

tab = constructTanakaYamashitaEfficient7(BigFloat)
sol1 =solve(probnum,TanYam7(),dt=1/2^6,adaptive=false,save_timeseries=false)
sol2 =solve(probnum,ExplicitRK(),dt=1/2^6,adaptive=false,save_timeseries=false, tableau=tab)

@test sol1.u[end] - sol2.u[end] < 1e-10

sol1 =solve(probbig,TanYam7(),dt=1/2^3,adaptive=false,save_timeseries=false)
sol2 =solve(probbig,ExplicitRK(),dt=1/2^3,adaptive=false,save_timeseries=false, tableau=tab)

@test minimum(sol1.u[end] - sol2.u[end] .< 1e-10)

sol1 =solve(prob,ExplicitRK(),dt=1/2^6,tableau=tab)
sol2 =solve(prob,TanYam7(),dt=1/2^6)

@test length(sol1) == length(sol2)

### Vern8()

dts = 1.//2.^(6:-1:3)
sim = test_convergence(dts,probnumbig,Vern8())
@test abs(sim.𝒪est[:l2]-8) < testTol
sim = test_convergence(dts,probbig,Vern8())
@test abs(sim.𝒪est[:l2]-8) < testTol

tab = constructVerner8(BigFloat)
sol1 =solve(probnumbig,Vern8(),dt=1/2^6,adaptive=false,save_timeseries=false)
sol2 =solve(probnumbig,ExplicitRK(),dt=1/2^6,adaptive=false,save_timeseries=false, tableau=tab)

@test sol1.u[end] - sol2.u[end] < 1e-10

sol1 =solve(probbig,Vern8(),dt=1/2^3,adaptive=false,save_timeseries=false)
sol2 =solve(probbig,ExplicitRK(),dt=1/2^3,adaptive=false,save_timeseries=false, tableau=tab)

@test minimum(sol1.u[end] - sol2.u[end] .< 1e-10)

sol1 =solve(prob,ExplicitRK(),dt=1/2^6,tableau=tab)
sol2 =solve(prob,Vern8(),dt=1/2^6)

@test length(sol1) == length(sol2)

### DP8()

dts = 1.//2.^(3:-1:1)
sim = test_convergence(dts,probnumbig,DP8())
@test abs(sim.𝒪est[:l2]-8) < testTol
sim = test_convergence(dts,probbig,DP8())
@test abs(sim.𝒪est[:l2]-8) < testTol

sol1 =solve(probnum,DP8(),dt=1/2^6,adaptive=false,save_timeseries=false)
sol2 =solve(probnum,DP8(),dt=1/2^6)

# Should be identical
sol1 =solve(probbig,DP8(),dt=1/2^6)
sol2 =solve(probbig,dop853(),dt=1/2^6)

@test length(sol1) == length(sol2)

### TsitPap8()

dts = 1.//2.^(6:-1:3)
sim = test_convergence(dts,probnumbig,TsitPap8())
@test abs(sim.𝒪est[:l2]-8) < testTol
sim = test_convergence(dts,probbig,TsitPap8())
@test abs(sim.𝒪est[:l2]-8) < testTol

tab = constructTsitourasPapakostas8(BigFloat)
sol1 =solve(probnumbig,TsitPap8(),dt=1/2^6,adaptive=false,save_timeseries=false)
sol2 =solve(probnumbig,ExplicitRK(),dt=1/2^6,adaptive=false,save_timeseries=false, tableau=tab)

@test sol1.u[end] - sol2.u[end] < 1e-10

sol1 =solve(probbig,TsitPap8(),dt=1/2^3,adaptive=false,save_timeseries=false)
sol2 =solve(probbig,ExplicitRK(),dt=1/2^3,adaptive=false,save_timeseries=false, tableau=tab)

@test minimum(sol1.u[end] - sol2.u[end] .< 1e-10)

sol1 =solve(prob,ExplicitRK(),dt=1/2^6,tableau=tab)
sol2 =solve(prob,TsitPap8(),dt=1/2^6)

@test length(sol1) == length(sol2)

### Vern9()

dts = 1.//2.^(6:-1:3)
sim = test_convergence(dts,probnumbig,Vern9())
@test abs(sim.𝒪est[:l2]-9) < testTol
sim = test_convergence(dts,probbig,Vern9())
@test abs(sim.𝒪est[:l2]-9) < testTol


tab = constructVernerEfficient9(BigFloat)
sol1 =solve(probnumbig,Vern9(),dt=1/2^6,adaptive=false,save_timeseries=false)
sol2 =solve(probnumbig,ExplicitRK(),dt=1/2^6,adaptive=false,save_timeseries=false, tableau=tab)

@test abs(sol1.u[end] - sol2.u[end]) < 1e-15

sol1 =solve(probbig,Vern9(),dt=1/2^3,adaptive=false,save_timeseries=false)
sol2 =solve(probbig,ExplicitRK(),dt=1/2^3,adaptive=false,save_timeseries=false, tableau=tab)

@test minimum(abs(sol1.u[end] - sol2.u[end]) .< 1e-15)

sol1 =solve(probbig,ExplicitRK(),dt=1/2^6,tableau=tab)
sol2 =solve(probbig,Vern9(),dt=1/2^6)

@test length(sol1) == length(sol2)
