# dbops-project
Исходный репозиторий для выполнения проекта дисциплины "DBOps"

До индексов:
store=# SELECT o.date_created, SUM(op.quantity)
FROM orders AS o
JOIN order_product AS op ON o.id = op.order_id
WHERE o.status = 'shipped' AND o.date_created > NOW() - INTERVAL '7 DAY'
GROUP BY o.date_created; 
 date_created |  sum   
--------------+--------
 2026-03-22   | 943469
 2026-03-23   | 941341
 2026-03-24   | 951997
 2026-03-25   | 954254
 2026-03-26   | 942433
 2026-03-27   | 943937
 2026-03-28   | 680441
(7 rows)

Time: 24287.175 ms (00:24.287)

store=# EXPLAIN ANALYZE SELECT o.date_created, SUM(op.quantity)
FROM orders AS o
JOIN order_product AS op ON o.id = op.order_id
WHERE o.status = 'shipped' AND o.date_created > NOW() - INTERVAL '7 DAY'
GROUP BY o.date_created;
                                                                              QUERY PLAN
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Finalize GroupAggregate  (cost=266075.34..266098.40 rows=91 width=12) (actual time=14057.850..14065.048 rows=7 loops=1)
   Group Key: o.date_created
   ->  Gather Merge  (cost=266075.34..266096.58 rows=182 width=12) (actual time=14057.815..14065.011 rows=21 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Sort  (cost=265075.32..265075.55 rows=91 width=12) (actual time=14037.216..14037.220 rows=7 loops=3)
               Sort Key: o.date_created
               Sort Method: quicksort  Memory: 25kB
GROUP BY o.date_created;
                                                                              QUERY PLAN
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Finalize GroupAggregate  (cost=266075.34..266098.40 rows=91 width=12) (actual time=14057.850..14065.048 rows=7 loops=1)
   Group Key: o.date_created
   ->  Gather Merge  (cost=266075.34..266096.58 rows=182 width=12) (actual time=14057.815..14065.011 rows=21 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Sort  (cost=265075.32..265075.55 rows=91 width=12) (actual time=14037.216..14037.220 rows=7 loops=3)
               Sort Key: o.date_created
               Sort Method: quicksort  Memory: 25kB
               Worker 0:  Sort Method: quicksort  Memory: 25kB
                                                                              QUERY PLAN
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Finalize GroupAggregate  (cost=266075.34..266098.40 rows=91 width=12) (actual time=14057.850..14065.048 rows=7 loops=1)
   Group Key: o.date_created
   ->  Gather Merge  (cost=266075.34..266096.58 rows=182 width=12) (actual time=14057.815..14065.011 rows=21 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Sort  (cost=265075.32..265075.55 rows=91 width=12) (actual time=14037.216..14037.220 rows=7 loops=3)
               Sort Key: o.date_created
               Sort Method: quicksort  Memory: 25kB
               Worker 0:  Sort Method: quicksort  Memory: 25kB
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Finalize GroupAggregate  (cost=266075.34..266098.40 rows=91 width=12) (actual time=14057.850..14065.048 rows=7 loops=1)
   Group Key: o.date_created
   ->  Gather Merge  (cost=266075.34..266096.58 rows=182 width=12) (actual time=14057.815..14065.011 rows=21 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Sort  (cost=265075.32..265075.55 rows=91 width=12) (actual time=14037.216..14037.220 rows=7 loops=3)
               Sort Key: o.date_created
               Sort Method: quicksort  Memory: 25kB
               Worker 0:  Sort Method: quicksort  Memory: 25kB
   Group Key: o.date_created
   ->  Gather Merge  (cost=266075.34..266096.58 rows=182 width=12) (actual time=14057.815..14065.011 rows=21 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Sort  (cost=265075.32..265075.55 rows=91 width=12) (actual time=14037.216..14037.220 rows=7 loops=3)
               Sort Key: o.date_created
               Sort Method: quicksort  Memory: 25kB
               Worker 0:  Sort Method: quicksort  Memory: 25kB
         Workers Launched: 2
         ->  Sort  (cost=265075.32..265075.55 rows=91 width=12) (actual time=14037.216..14037.220 rows=7 loops=3)
               Sort Key: o.date_created
               Sort Method: quicksort  Memory: 25kB
               Worker 0:  Sort Method: quicksort  Memory: 25kB
               Sort Key: o.date_created
               Sort Method: quicksort  Memory: 25kB
               Worker 0:  Sort Method: quicksort  Memory: 25kB
               Sort Method: quicksort  Memory: 25kB
               Worker 0:  Sort Method: quicksort  Memory: 25kB
               Worker 1:  Sort Method: quicksort  Memory: 25kB
               Worker 0:  Sort Method: quicksort  Memory: 25kB
               Worker 1:  Sort Method: quicksort  Memory: 25kB
               ->  Partial HashAggregate  (cost=265071.45..265072.36 rows=91 width=12) (actual time=14037.195..14037.200 rows=7 loops=3)
               Worker 1:  Sort Method: quicksort  Memory: 25kB
               ->  Partial HashAggregate  (cost=265071.45..265072.36 rows=91 width=12) (actual time=14037.195..14037.200 rows=7 loops=3)
               ->  Partial HashAggregate  (cost=265071.45..265072.36 rows=91 width=12) (actual time=14037.195..14037.200 rows=7 loops=3)
                     Group Key: o.date_created
                     Batches: 1  Memory Usage: 24kB
                     Worker 0:  Batches: 1  Memory Usage: 24kB
                     Worker 1:  Batches: 1  Memory Usage: 24kB
                     ->  Parallel Hash Join  (cost=148274.78..264573.27 rows=99636 width=8) (actual time=8198.164..14010.007 rows=83113 loops=3)
                           Hash Cond: (op.order_id = o.id)
                           ->  Parallel Seq Scan on order_product op  (cost=0.00..105361.13 rows=4166613 width=12) (actual time=0.035..4589.582 rows=3333333 loops=3)
                           ->  Parallel Hash  (cost=147029.29..147029.29 rows=99639 width=12) (actual time=8196.888..8196.889 rows=83113 loops=3)
                                 Buckets: 262144  Batches: 1  Memory Usage: 13792kB
                                 ->  Parallel Seq Scan on orders o  (cost=0.00..147029.29 rows=99639 width=12) (actual time=7.849..8153.706 rows=83113 loops=3)
                                       Filter: (((status)::text = 'shipped'::text) AND (date_created > (now() - '7 days'::interval)))
                                       Rows Removed by Filter: 3250221
 Planning Time: 0.238 ms
 JIT:
   Functions: 54
   Options: Inlining false, Optimization false, Expressions true, Deforming true
   Timing: Generation 2.342 ms, Inlining 0.000 ms, Optimization 1.081 ms, Emission 22.497 ms, Total 25.921 ms
 Execution Time: 14065.882 ms
(29 rows)



После индексов: 

