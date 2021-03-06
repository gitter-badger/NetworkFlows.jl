using NetworkFlows
using Base.Test

## Test link.jl ##
#import NetworkFlows.zero_to_one!
@test zero_to_one!([(0,1),(1,2)]) == [(1,2),(2,3)]
@test zero_to_one!([(3,1),(1,2)]) != [(3,1),(1,2)]
@test zero_to_one!([(0,1,1.),(1,2,2.)]) == [(1,2,1.),(2,3,2.)]
@test zero_to_one!([(3,1,0.),(1,2,-2.1)]) != [(3,1,0.),(1,2,-2.1)]

import NetworkFlows.Arc, NetworkFlows.ghostArc, NetworkFlows.simpleArc
@test Arc(0,1,0.).sym == ghostArc(1).sym
@test Arc(0,1,0.).head == ghostArc(1).head
@test Arc(0,1,0.).cap == ghostArc(1).cap
@test Arc(0,2,1.).sym == simpleArc(2).sym
@test Arc(0,2,1.).head == simpleArc(2).head
@test Arc(0,2,1.).cap == simpleArc(2).cap

## Test network.jl
import NetworkFlows.Network, NetworkFlows.findArc
g1 = Network(1,2,[1,2,2],[Arc(0,2,1.)])
g2 = Network(2,1,[1,2,2],[simpleArc(2)])
@test g1.source == g2.target
@test g2.source == g1.target
@test g1.tails == g2.tails
@test length(g1.links) == length(g2.links)
@test findArc(g1,1,2) == findArc(g2,1,2)

## Test io.jl
#import NetworkFlows.print
edges1 = [(0,1,5.),(0,2,7.),(0,5,1.75),(0,6,1.3),(1,3,2.),(2,1,1.),
  (2,3,11.),(2,4,8.),(3,5,6.),(4,5,3.),(6,5,1.25)]
zero_to_one!(edges1)
g3 = Network(edges1, true, 1, 6)
print(g3)

import NetworkFlows.orderedDIMACS
orderedDIMACS(pwd()*"/../ioexample/unordereddimacs",
  pwd()*"/../ioexample/ordereddimacs")
gdimacs = Network(pwd()*"/../ioexample/ordereddimacs",:DIMACS)
gcsv = Network(pwd()*"/../ioexample/csv",:CSV,(1,6))

## Test search.jl
import NetworkFlows.bfs
println("BFS: ",bfs(g3,:Path))

## Test flow.jl
# import NetworkFlows.edmondsKarp, NetworkFlows.connectivity
# import NetworkFlows.kishimoto
@test edmondsKarp(g3)[1] == 12
@test connectivity(g3) == 4
@test edmondsKarp(gdimacs)[1] == 15
@test edmondsKarp(gcsv)[1] == 15
edges2 =
[(1,2,10.),(1,3,20.),(1,4,40.),(1,5,80.),(2,6,1.),(3,6,2.),(4,6,4.),(5,6,8.)]
g4 = Network(edges2,true,1,6)
@test kishimoto(g4,1)[1] == edmondsKarp(g4)[1]
@test kishimoto(g4,2)[1] == 14.
@test kishimoto(g4,3)[1] == 9.
@test kishimoto(g4,4)[1] == 4.

## Test cut.jl
#import NetworkFlows.mincut
@test mincut(g3)[1] == edmondsKarp(g3)[1]
@test mincut(g3)[2] != edmondsKarp(g3)[2]

# Test extmrflow
# import NetworkFlows.breakingPoints
@test breakingPoints(g4) ==
  [(0.,0.,4),(1.0,4.0,3),(2.0,7.0,2),(4.0,11.0,1),(8.0,15.0,0)]
edges3 =
[(1,2,10.),(1,3,20.),(1,4,40.),(1,5,80.),(2,6,2.),(3,6,2.),(4,6,2.),(5,6,8.)]
g5 = Network(edges3,true,1,6)
@test breakingPoints(g5) ==
  [(0.0,0.0,4),(-1.0,-1.0,3),(-1.0,-1.0,2),(2.0,8.0,1),(4.0,14.0,0)]

  # Test mla.jl
  # import NetworkFlows.mixedMLA, NetworkFlows.successMLA
  edges4 = [(1,2,2.),(1,3,3.),(1,4,5.),(2,5,2.),(3,5,3.),(4,5,5.),
    (5,6,3.),(5,7,3.),(5,8,3.),(6,9,3.),(7,9,3.),(8,9,3.),
    (9,10,7.),(9,11,7.),(10,12,7.),(11,12,7.)]
  g6 = Network(edges4,true,1,12)
  @test mixedMLA(g6) == [(4.5,6.0),(9.0,9.0)]
  @test successMLA(g6) == 0.5
