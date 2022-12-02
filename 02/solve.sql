-- setup
create schema if not exists day2;
drop table day2.input;
create table day2.input (line SERIAL, opp text, player text);
copy day2.input (opp, player)
from '/workspace/02/input.txt' DELIMITER ' ';
-- setup game rules table
create table day2.rock_paper_scissors (type text, beats text, loses text, value int);
insert into day2.rock_paper_scissors (type, beats, loses, value)
values ('Rock', 'Scissors', 'Paper', 1),
    ('Paper', 'Rock', 'Scissors', 2),
    ('Scissors', 'Paper', 'Rock', 3);
-- part 1
with decode_opp as (
    (
        select 'A' as opp,
            *
        from day2.rock_paper_scissors
        where type = 'Rock'
    )
    UNION
    (
        select 'B',
            *
        from day2.rock_paper_scissors
        where type = 'Paper'
    )
    UNION
    (
        select 'C',
            *
        from day2.rock_paper_scissors
        where type = 'Scissors'
    )
),
decode_player as (
    (
        select 'X' as player,
            *
        from day2.rock_paper_scissors
        where type = 'Rock'
    )
    UNION
    (
        select 'Y',
            *
        from day2.rock_paper_scissors
        where type = 'Paper'
    )
    UNION
    (
        select 'Z',
            *
        from day2.rock_paper_scissors
        where type = 'Scissors'
    )
),
round_results as (
    select decode_player.value as score,
        case
            when decode_opp.type = decode_player.type then 3
            when decode_opp.beats = decode_player.type then 0
            else 6
        end as outcome
    from day2.input
        join decode_opp using(opp)
        join decode_player using(player)
)
select sum(score + outcome)
from round_results;
-- part 2
with decode_opp as (
    (
        select 'A' as opp,
            *
        from day2.rock_paper_scissors
        where type = 'Rock'
    )
    UNION
    (
        select 'B',
            *
        from day2.rock_paper_scissors
        where type = 'Paper'
    )
    UNION
    (
        select 'C',
            *
        from day2.rock_paper_scissors
        where type = 'Scissors'
    )
),
part_2_result as (
    select input.*,
        decode_opp.type,
        player.*,
        case
            when input.player = 'X' then 0
            when input.player = 'Y' then 3
            else 6
        end as outcome
    from day2.input
        join decode_opp using(opp)
        join day2.rock_paper_scissors as player on (
            (
                input.player = 'X'
                and decode_opp.type = player.loses
            )
            or (
                input.player = 'Y'
                and decode_opp.type = player.type
            )
            or (
                input.player = 'Z'
                and decode_opp.type = player.beats
            )
        )
)
select sum(value + outcome)
from part_2_result;