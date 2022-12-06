create schema day6;
drop table if exists day6.input;
create table day6.input(sequence serial, value text);
delete from day6.input;
copy day6.input(sequence, value)
from PROGRAM 'awk ''BEGIN {FS=""} {for(i=1;i<NF;i++) print i,$i}'' /workspace/06/input.txt' DELIMITER ' ';
--- part 1 answer
with tuples as (
    select *,
        value as a,
        lead(value, 1) over(
            order by sequence
        ) as b,
        lead(value, 2) over(
            order by sequence
        ) as c,
        lead(value, 3) over(
            order by sequence
        ) as d
    from day6.input
),
keys as (
    select sequence + 3 as column,
        concat(a, b, c, d) as key
    from tuples
    where (
            a not in (b, c, d)
            and b not in (a, c, d)
            and c not in (a, b, d)
            and d not in (a, b, c)
        )
    order by sequence asc
)
select *
from keys
limit 1;
-- part 2 answer
with RECURSIVE search_tree(sequence, value, key, depth) as (
    select sequence,
        value,
        value,
        1
    from day6.input part1
    UNION
    select p2.sequence,
        p2.value,
        concat(p1.key, p2.value),
        p1.depth::int + 1 as depth
    from search_tree p1
        join day6.input p2 on p1.sequence + 1 = p2.sequence
    where position(p2.value in p1.key) = 0
        and depth < 30
)
select *
from search_tree
order by depth desc
limit 1;