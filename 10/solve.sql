drop schema if exists day10 cascade;
create schema day10;
create table day10.input(clock int, add_x int);
delete from day10.input;
copy day10.input(clock, add_x)
from PROGRAM 'awk ''BEGIN{FS=" "}/addx/{p += 2;print p,$2}/noop/{p++}'' /workspace/10/input.txt' DELIMITER ' ';
---
with intervals(i) as (
	select generate_series + 20 as i
	from generate_series(0, 200, 40)
),
interval_strength as (
	select intervals.i,
		intervals.i * (sum(add_x) + 1) as strength
	from intervals
		join day10.input on(clock < intervals.i)
	group by intervals.i
	order by intervals.i
),
part_1_answer as (
	select sum(strength) as "part 1 answer"
	from interval_strength
),
clock(i) as (
	select *
	from generate_series(1, 500)
),
clock_strength as (
	select clock.i as clock,
		(clock.i -1) % 40 as pos,
		(clock.i -1) / 40 as row,
		sum(coalesce(add_x, 0)) + 1 as strength
	from clock
		left join day10.input on(clock < clock.i)
	group by clock.i
	order by clock.i
),
rendered_pixels as (
	select *,
		abs(pos - strength) as render
	from clock_strength
),
crt as (
	select row,
		pos,
		case
			when abs(render) < 2 then '#'
			else '.'
		end as value,
		strength,
		render
	from rendered_pixels
	order by row,
		pos
),
part_2_answer as (
	select row as row_num,
		string_agg(
			value,
			' '
			order by pos
		) as row
	from crt
	where row < 6
	group by row_num
	order by row_num asc
)
select row
from part_2_answer;
/*  Result
 "row"
 "# # # # . # # # . . . # # . . # # # . . # . . . . # # # # . # # # # . # . . # ."
 ". . . # . # . . # . # . . # . # . . # . # . . . . # . . . . . . . # . # . . # ."
 ". . # . . # . . # . # . . # . # . . # . # . . . . # # # . . . . # . . # . . # ."
 ". # . . . # # # . . # # # # . # # # . . # . . . . # . . . . . # . . . # . . # ."
 "# . . . . # . # . . # . . # . # . # . . # . . . . # . . . . # . . . . # . . # ."
 "# # # # . # . . # . # . . # . # . . # . # # # # . # . . . . # # # # . . # # . ."
 */