create schema day8;
create table day8.input(pos_x int, pos_y int, height int);
delete from day8.input;
copy day8.input(pos_x, pos_y, height)
from PROGRAM 'awk ''
BEGIN{FS=""}{ for(i=1;i<=NF;i++) print i, NR, $i }
'' /workspace/08/input.txt' DELIMITER ' ';

with visible_left as (
    select input.pos_x,
        input.pos_y,
        input.height
    from day8.input
        left join day8.input blocked on (
            blocked.pos_x < input.pos_x
            and blocked.pos_y = input.pos_y
            and blocked.height >= input.height
        )
    where blocked.height is null
),
visible_right as (
    select input.pos_x,
        input.pos_y,
        input.height
    from day8.input
        left join day8.input blocked on (
            blocked.pos_x > input.pos_x
            and blocked.pos_y = input.pos_y
            and blocked.height >= input.height
        )
    where blocked.height is null
),
visible_top as (
    select input.pos_x,
        input.pos_y,
        input.height
    from day8.input
        left join day8.input blocked on (
            blocked.pos_x = input.pos_x
            and blocked.pos_y > input.pos_y
            and blocked.height >= input.height
        )
    where blocked.height is null
),
visible_bottom as (
    select input.pos_x,
        input.pos_y,
        input.height
    from day8.input
        left join day8.input blocked on (
            blocked.pos_x = input.pos_x
            and blocked.pos_y < input.pos_y
            and blocked.height >= input.height
        )
    where blocked.height is null
),
all_visible as (
    select *
    from visible_left
    UNION
    select *
    from visible_right
    union
    select *
    from visible_top
    union
    select *
    from visible_bottom
),
part_1_answer as (
	select count(*) as "part 1 answer"
	from all_visible
);


with input as (
	with grid_size as (
	select (select max(pos_x) from day8.input) as max_x,
	(select max(pos_y) from day8.input) as max_y
	)
	select * from day8.input, grid_size
),visible_score_left as (
    select input.pos_x,
        input.pos_y,
        input.height,
        max(blocked.pos_x),
        input.pos_x - coalesce(max(blocked.pos_x), 1) as score
    from input
        left join day8.input blocked on (
            blocked.pos_x < input.pos_x
            and blocked.pos_y = input.pos_y
            and blocked.height >= input.height
        )
    group by input.pos_x, input.pos_y, input.height
),
visible_score_right as (
    select input.pos_x,
        input.pos_y,
        input.height,
        min(blocked.pos_x),
        coalesce(min(blocked.pos_x), max(max_x)) - input.pos_x as score
    from input
        left join day8.input blocked on (
            blocked.pos_x > input.pos_x
            and blocked.pos_y = input.pos_y
            and blocked.height >= input.height
        )
    group by input.pos_x, input.pos_y, input.height
),
visible_score_up as (
    select input.pos_x,
        input.pos_y,
        input.height,
        max(blocked.pos_y),
        input.pos_y - coalesce(max(blocked.pos_y), 1) as score
    from input
        left join day8.input blocked on (
            blocked.pos_x = input.pos_x
            and blocked.pos_y < input.pos_y
            and blocked.height >= input.height
        )
    group by input.pos_x, input.pos_y, input.height
),
visible_score_down as (
    select input.pos_x,
        input.pos_y,
        input.height,
        min(blocked.pos_y),
        coalesce(min(blocked.pos_y), max(max_y)) - input.pos_y as score
    from input
        left join day8.input blocked on (
            blocked.pos_x = input.pos_x
            and blocked.pos_y > input.pos_y
            and blocked.height >= input.height
        )
    group by input.pos_x, input.pos_y, input.height
),
scores as (
select pos_x, pos_y, height, 
visible_score_left.score * visible_score_right.score * visible_score_up.score * visible_score_down.score as score
from visible_score_left
join visible_score_right using(pos_x,pos_y, height)
join visible_score_up using(pos_x,pos_y, height)
join visible_score_down using(pos_x,pos_y, height)
)
select score as "part 2 answer" from scores
order by score DESC
limit 1
;