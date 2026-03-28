# dbops-project

**Выдача прав**:  
Был сделан пользователь autotests
```
CREATE USER "autotests" WITH PASSWORD 'password';
GRANT CONNECT ON DATABASE store TO autotests;
GRANT USAGE, CREATE ON SCHEMA public TO autotests;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO autotests;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO autotests;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO autotests;
```

**Запрос:**
```
SELECT o.date_created, SUM(op.quantity)
FROM orders AS o
JOIN order_product AS op ON o.id = op.order_id
WHERE o.status = 'shipped' AND o.date_created > NOW() - INTERVAL '7 DAY'
GROUP BY o.date_created; 
```

**До индексов:**  
Time: 38648.368 ms (00:38.648)

Вывод EXPLAIN ANALYZE  
```
QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Finalize GroupAggregate  (cost=266075.06..266098.12 rows=91 width=12) (actual time=35668.344..35741.035 rows=7 loops=1)
   Group Key: o.date_created
   ->  Gather Merge  (cost=266075.06..266096.30 rows=182 width=12) (actual time=35668.320..35741.009 rows=21 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Sort  (cost=265075.04..265075.26 rows=91 width=12) (actual time=35475.549..35475.553 rows=7 loops=3)
               Sort Key: o.date_created
               Sort Method: quicksort  Memory: 25kB
               Worker 0:  Sort Method: quicksort  Memory: 25kB
               Worker 1:  Sort Method: quicksort  Memory: 25kB
               ->  Partial HashAggregate  (cost=265071.17..265072.08 rows=91 width=12) (actual time=35475.525..35475.529 rows=7 loops=3)
                     Group Key: o.date_created
                     Batches: 1  Memory Usage: 24kB
                     Worker 0:  Batches: 1  Memory Usage: 24kB
                     Worker 1:  Batches: 1  Memory Usage: 24kB
                     ->  Parallel Hash Join  (cost=148273.81..264572.98 rows=99638 width=8) (actual time=16851.605..35454.665 rows=83113 loops=3)
                           Hash Cond: (op.order_id = o.id)
                           ->  Parallel Seq Scan on order_product op  (cost=0.00..105361.67 rows=4166667 width=12) (actual time=11.104..17504.339 rows=3333333 loops=3)
                           ->  Parallel Hash  (cost=147028.33..147028.33 rows=99638 width=12) (actual time=16839.710..16839.711 rows=83113 loops=3)
                                 Buckets: 262144  Batches: 1  Memory Usage: 13792kB
                                 ->  Parallel Seq Scan on orders o  (cost=0.00..147028.33 rows=99638 width=12) (actual time=15.899..16793.715 rows=83113 loops=3)
                                       Filter: (((status)::text = 'shipped'::text) AND (date_created > (now() - '7 days'::interval)))
                                       Rows Removed by Filter: 3250221
 Planning Time: 0.239 ms
 JIT:
   Functions: 54
   Options: Inlining false, Optimization false, Expressions true, Deforming true
   Timing: Generation 2.864 ms, Inlining 0.000 ms, Optimization 1.417 ms, Emission 28.834 ms, Total 33.116 ms
 Execution Time: 35741.944 ms
(29 rows)

Time: 35742.728 ms (00:35.743)
```




**После индексов:** 


Time: 1847.036 ms (00:01.847)

```
Вывод EXPLAIN ANALYZE
                                                                                        QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
 Finalize GroupAggregate  (cost=188014.00..188037.05 rows=91 width=12) (actual time=1803.838..1811.553 rows=7 loops=1)
   Group Key: o.date_created
   ->  Gather Merge  (cost=188014.00..188035.23 rows=182 width=12) (actual time=1803.825..1811.538 rows=21 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Sort  (cost=187013.98..187014.20 rows=91 width=12) (actual time=1767.459..1767.463 rows=7 loops=3)
               Sort Key: o.date_created
               Sort Method: quicksort  Memory: 25kB
               Worker 0:  Sort Method: quicksort  Memory: 25kB
               Worker 1:  Sort Method: quicksort  Memory: 25kB
               ->  Partial HashAggregate  (cost=187010.11..187011.02 rows=91 width=12) (actual time=1767.436..1767.440 rows=7 loops=3)
                     Group Key: o.date_created
                     Batches: 1  Memory Usage: 24kB
                     Worker 0:  Batches: 1  Memory Usage: 24kB
                     Worker 1:  Batches: 1  Memory Usage: 24kB
                     ->  Parallel Hash Join  (cost=70212.75..186511.92 rows=99638 width=8) (actual time=238.184..1745.278 rows=83113 loops=3)
                           Hash Cond: (op.order_id = o.id)
                           ->  Parallel Seq Scan on order_product op  (cost=0.00..105361.67 rows=4166667 width=12) (actual time=0.024..396.156 rows=3333333 loops=3)
                           ->  Parallel Hash  (cost=68967.27..68967.27 rows=99638 width=12) (actual time=236.650..236.651 rows=83113 loops=3)
                                 Buckets: 262144  Batches: 1  Memory Usage: 13824kB
                                 ->  Parallel Bitmap Heap Scan on orders o  (cost=3279.52..68967.27 rows=99638 width=12) (actual time=25.622..202.199 rows=83113 loops=3)
                                       Recheck Cond: (((status)::text = 'shipped'::text) AND (date_created > (now() - '7 days'::interval)))
                                       Heap Blocks: exact=29282
                                       ->  Bitmap Index Scan on idx_orders_status_date_created  (cost=0.00..3219.74 rows=239130 width=0) (actual time=30.629..30.629 rows=249338 loops=1)     
                                             Index Cond: (((status)::text = 'shipped'::text) AND (date_created > (now() - '7 days'::interval)))
 Planning Time: 0.438 ms
 JIT:
   Functions: 57
   Options: Inlining false, Optimization false, Expressions true, Deforming true
   Timing: Generation 4.646 ms, Inlining 0.000 ms, Optimization 4.204 ms, Emission 37.018 ms, Total 45.868 ms
 Execution Time: 1812.588 ms
(31 rows)

Time: 1813.664 ms (00:01.814)
```

**Вывод:**  
Время запроса снизилось с 38.6 секунд до 1.8 секунд(в 21 раз быстрее)