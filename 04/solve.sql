create schema day4;
drop table if exists day4.input;
create table day4.input(
    line serial,
    start_a int,
    end_a int,
    start_b int,
    end_b int
);
delete from day4.input;
copy day4.input(start_a, end_a, start_b, end_b)
from PROGRAM 'awk ''BEGIN {FS=",|-"} {print $1, $2, $3, $4}'' /workspace/04/input.txt' DELIMITER ' ';

select *
from day4.input_sample;
with pairs as (
    select *
    from day4.input
),
containing_pairs as (
    select *
    from pairs
    where (
            start_a <= start_b
            and end_a >= end_b
        )
        OR (
            start_b <= start_a
            and end_b >= end_a
        )
),
overlapping_pairs as (
    select *
    from pairs
    where (
            start_a <= start_b
            and start_b <= end_a
        )
        OR (
            start_a <= end_b
            and end_b <= end_a
        )
        OR (
            start_b <= start_a
            and start_a <= end_b
        )
        OR (
            start_b <= end_a
            and end_a <= end_b
        )
)
select (
        select count(*)
        from containing_pairs
    ) as "answer part 1",
    (
        select count(*)
        from overlapping_pairs
    ) as "answer part 2";
