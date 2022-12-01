create schema if not exists day1;
drop table day1.input;
create table day1.input (line SERIAL, text text);
copy day1.input (text)
from '/workspace/01/input.txt' DELIMITER ' ';

with elfs_ids as (
    select *
    from day1.input
    where text = ''
    UNION
    select 0 as line,
        '' as text
),
elfs as (
    select rank() over (
            order by line
        ) as elf_id,
        line as start_line,
        lead(line, 1) over (
            order by line
        ) as end_line
    from elfs_ids
),
part_1_answer as (
    select elf_id,
        sum(text::int) as total
    from elfs
        join day1.input on input.line > elfs.start_line
        and input.line < elfs.end_line
    group by elf_id
    order by sum(text::int) desc
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
    ) (
        select total as "part 2 answer"
        from part_2_answer
    ),
;
