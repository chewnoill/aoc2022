create schema if not exists day1;
drop table day1.input;
create table day1.input (line SERIAL, elf_id int, amount int);

copy day1.input (elf_id, amount)
from PROGRAM 'awk ''BEGIN {RS = "\n\n"} {for (i = 1; i <= NF; i++) print NR,$i}'' /workspace/01/input.txt' DELIMITER ' ';

with part_1_answer as (
    select elf_id,
        sum(amount) as total
    from day1.input
    group by elf_id
    order by sum(amount) desc
),
part_2_answer as (
    with top_3 as (
        select *
        from part_1_answer
        limit 3
    )
    select sum(total) as total
    from top_3
)
select (
        select total as "part 1 answer"
        from part_1_answer
        limit 1
    ), (
        select total as "part 2 answer"
        from part_2_answer
    )
;
