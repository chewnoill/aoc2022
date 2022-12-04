-- Setup tables
create schema if not exists day3;
drop table if exists day3.input;
create table day3.input (
    line SERIAL,
    rucksack int,
    position int,
    first_half bool,
    type text
);
-- Parse input
delete from day3.input;
copy day3.input (rucksack, position, first_half, type)
from PROGRAM 'awk ''BEGIN {FS=""}
{
  for (i = 1; i <= NF; i++)
  	print NR,i,i<=(NF/2),$i
}
'' /workspace/03/input.txt' DELIMITER ' ';
select *
from day3.input;
-- Calculate puzzle answers
with
values as (
        with lower_case as (
            with
            values as (
                    select generate_series(1, 26) as value
                )
            select value,
                chr(ascii('a') + value -1) as type
            from
            values
        ),
        upper_case as (
            with
            values as (
                    select generate_series(27, 52) as value
                )
            select value,
                chr(ascii('A') + value -27) as type
            from
            values
        )
        select *
        from upper_case
            full join lower_case using(value, type)
        order by value
    ),
    duplicates as (
        select input.rucksack,
            input.type,
            value
        from day3.input
            join day3.input input_b on (
                input.rucksack = input_b.rucksack
                and input.first_half = true
                and input_b.first_half = FALSE
                and input.type = input_b.type
            )
            join
        values on input.type =
        values.type
        group by input.rucksack,
            input.type,
            value
    ),
    -- Part 1: Answer
    part_1_answer as (
        select sum(value) as "part 1 answer"
        from duplicates
    ),
    grouped_input as(
        with rucksack_groups as (
            select rucksack,
                (rucksack -1) / 3 as group,
                rucksack -((rucksack -1) / 3) * 3 as group_member
            from day3.input
            group by rucksack
        )
        select *
        from day3.input
            join rucksack_groups using(rucksack)
    ),
    group_ids as (
        select input.group,
            input.type,
            values.value
        from grouped_input input
            join grouped_input input_2 on (
                input.group = input_2.group
                and input.group_member = 1
                and input_2.group_member = 2
                and input.type = input_2.type
            )
            join grouped_input input_3 on (
                input.group = input_3.group
                and input.group_member = 1
                and input_3.group_member = 3
                and input.type = input_3.type
            )
            join
        values on input.type =
        values.type
        group by input.group,
            input.type,
            values.value
    )
select (
        select sum(value)
        from group_ids
    ) as "part 2 answer",
    (
        select *
        from part_1_answer
    );
