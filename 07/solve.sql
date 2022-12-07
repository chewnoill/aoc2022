create schema day7;
drop table if exists day7.input;
create table day7.input(
    sequence serial,
    path text,
    filename text,
    size int
);
delete from day7.input;
copy day7.input(path, filename, size)
from PROGRAM 'awk ''
BEGIN {
    RS="$"
    delete arr[0]
    FS=" |\n"
}
/cd/ {
    if($3 == ".."){
        delete arr[length(arr)-1];
    } else {
        arr[length(arr)] = $3;
    }
    path="/"
    for(i=1;i<length(arr);i++){
        path = path arr[i] "/"
    }
}
/ls/ {
    print path,".",0
    for(i=3;i<=NF;i+=2){
        size = $i
        name = $(i+1)
        if(size != "dir" && length(name)>0){
            print path,name,size
        }
    }
}
'' /workspace/07/input.txt' DELIMITER ' ';
select *
from day7.input;
--- part 1 answer
with dir_sizes as (
    select path,
        sum(size) as size
    from day7.input
    group by path
),
sizes_with_children as (
    select parent.path as path,
        parent.size as parent_size,
        sum(coalesce(child.size, 0)) as child_size
    from dir_sizes parent
        left join dir_sizes child on position(parent.path in child.path) = 1
        and parent.path <> child.path
    group by parent.path,
        parent.size
),
total_sizes as (
    select path,
        parent_size + child_size as total_size
    from sizes_with_children
),
part_1_answer as (
    select sum(total_size) as "part 1 answer"
    from total_sizes
    where total_size <= 100000
),
free_space as (
    select 70000000 - total_size as space
    from total_sizes
    where path = '/'
    limit 1
), part_2_answer as (
    select total_size as "part 2 answer"
    from total_sizes,
        free_space
    where total_size + free_space.space >= 30000000
    order by total_size asc
    limit 1
)
select *
from part_1_answer,
    part_2_answer;