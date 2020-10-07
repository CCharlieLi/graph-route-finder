# graph-route-finder

[![Build Status](https://travis-ci.com/CCharlieLi/graph-route-finder.svg?branch=main)](https://travis-ci.com/CCharlieLi/graph-route-finder)
[![Coverage Status](https://coveralls.io/repos/github/CCharlieLi/graph-route-finder/badge.svg?branch=main)](https://coveralls.io/github/CCharlieLi/graph-route-finder?branch=main)

Find all/least-cost routes in weighted directed graph with given limitations. The idea of this lib is to find all possible routes, including the least-cost one, in a weighted directed graph which is commonly used in delivery services. With a bunch of limitations, it can be used in many scenarios. For example, find all possible routes from A to B, while total cost should be less than 20, whole stops should be less than 4.

## How to use

### Init graph

```js
const Graph = require('graph-route-finder');

const graph = new Graph({
      A: { B: 1, C: 4, D: 10 },
      B: { E: 3 },
      C: { D: 4, F: 2 },
      D: { E: 1 },
      E: { B: 3, A: 2 },
      F: { D: 1 },
    }); 

console.log(graph.nodes)
// {
//   A: { B: 1, C: 4, D: 10 },
//   B: { E: 3 },
//   C: { D: 4, F: 2 },
//   D: { E: 1 },
//   E: { B: 3, A: 2 },
//   F: { D: 1 },
// }
```

### Refresh graph

#### graph.refresh(nodes)

Which will remove previous nodes and add provided graph nodes to totally refresh graph instance.

```js
graph.refresh({ J: { A: 10 } });

console.log(graph.nodes)
// { J: { A: 10 } }
```

### Get all nodes that start from the given node

#### graph.from(nodeName)

```js
console.log(graph.from('A'));
// { B: 1, C: 4, D: 10 }
```

### Get all nodes that direct to the given node

#### graph.to(nodeName)

```js
console.log(graph.to('B'))
// { A: { B: 1 }, E: { B: 3 } }
```

### Add a new route or update a existent route

#### graph.set(startNode, endNode [, cost])

By default, cost will be 1 if not provided.

```js
graph.set('A', 'J', 12);
console.log(graph.nodes);
// {
//   A: { B: 1, C: 4, D: 10, J: 12 },
//   B: { E: 3 },
//   C: { D: 4, F: 2 },
//   D: { E: 1 },
//   E: { B: 3, A: 2 },
//   F: { D: 1 },
// }

graph.set('A', 'B', 12);
console.log(graph.nodes);
// {
//   A: { B: 12, C: 4, D: 10, J: 12 },
//   B: { E: 3 },
//   C: { D: 4, F: 2 },
//   D: { E: 1 },
//   E: { B: 3, A: 2 },
//   F: { D: 1 },
// }
```

### Remove a existent route

#### graph.remove(startNode, endNode)

Trying to remove a non-existent route will result in no change in graph.

```js
graph.remove('A', 'B');
console.log(graph.nodes);
// {
//   A: { C: 4, D: 10 },
//   B: { E: 3 },
//   C: { D: 4, F: 2 },
//   D: { E: 1 },
//   E: { B: 3, A: 2 },
//   F: { D: 1 },
// }
```

### Calculate cost for given route(a array of nodes)

#### graph.calculate([nodeName1, nodeName2, ...])

This function will go through each node to the next from given node array to calculate cost for the whole route, if a path is not found in the route, `No​ ​Such​ ​Route` error will be returned.

```js
graph.calculate(['E', 'A', 'C', 'F'])
// 8

graph.calculate(['A', 'D', 'F']);
// Error { message: 'No​ ​Such​ ​Route }
```


### Find routes for given start node and end node

#### graph.findRoutes(startNode, endNode [, options ])

This function will return a list of all possible routes from start node to end node. The list will be sorted by cost ASC.
- Options:
  - `routeLimit`: Infinity. How many routes to return, by giving `routeLimit:1`, it will return only one route which is also the least-cost route.
  - `stopLimit`: Infinity. The maximum stops the routes can reach.
  - `costLimit`: Infinity. The maximum cost the routes can reach.
  - `pathReuseLimit`: 1. **Experiment** How many time the same route can be reused.

```js
const routes = graph.findRoutes('E', 'D', { stopLimit: 4 });
// [
//   {
//     nodes: [ 'E', 'A', 'C', 'F', 'D' ],
//     paths: { 'E-A': 1, 'A-C': 1, 'C-F': 1, 'F-D': 1 },
//     cost: 9
//   },
//   {
//     nodes: [ 'E', 'A', 'C', 'D' ],
//     paths: { 'E-A': 1, 'A-C': 1, 'C-D': 1 },
//     cost: 10
//   },
//   { 
//     nodes: [ 'E', 'A', 'D' ], 
//     paths: { 'E-A': 1, 'A-D': 1 }, 
//     cost: 12 
//   },
//   {
//     nodes: [ 'E', 'B', 'E', 'A', 'D' ],
//     paths: { 'E-B': 1, 'B-E': 1, 'E-A': 1, 'A-D': 1 },
//     cost: 18
//   }
// ]

const routes = graph.findRoutes('E', 'E', { costLimit: 10 });
// [
//   { 
//     nodes: [ 'E', 'B', 'E' ], 
//     paths: { 'E-B': 1, 'B-E': 1 }, 
//     cost: 6 },
//   {
//     nodes: [ 'E', 'A', 'B', 'E' ],
//     paths: { 'E-A': 1, 'A-B': 1, 'B-E': 1 },
//     cost: 6
//   },
//   {
//     nodes: [ 'E', 'A', 'C', 'F', 'D', 'E' ],
//     paths: { 'E-A': 1, 'A-C': 1, 'C-F': 1, 'F-D': 1, 'D-E': 1 },
//     cost: 10
//   }
// ]

const routes = graph.findRoutes('E', 'E', { routeLimit: 1 });
// [
//   { nodes: [ 'E', 'B', 'E' ], paths: { 'E-B': 1, 'B-E': 1 }, cost: 6 }
// ]
```

## How to test

```bash
yarn test
```

## [License](https://github.com/CCharlieLi/graph-route-finder/blob/main/LICENSE)