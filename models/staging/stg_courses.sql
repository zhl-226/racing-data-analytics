-- =============================================================================
-- stg_courses  (done)
-- =============================================================================
-- Purpose: a clean course-route dimension, with the encoded Japanese route
-- string decoded into structured fields.
--
-- Source: {{ ref('courses') }} (the seed) has columns:
--   course_id    integer
--   course_name  varchar   e.g. 'ダ右1700m'
--
-- The course_name encodes the route, but there are TWO formats (dirty data!):
--   '{surface}{direction}{distance}m'   e.g. 'ダ右1700m'  -> dirt, right, 1700m
--   '{direction}{distance}m'            e.g. '直200m'     -> straight, 200m (no surface char)
--
-- Decoding rules:
--   surface:    char 1 when it is a surface char
--                 (ダ = dirt, 芝 = turf, 障 = steeplechase)
--               NULL for straight routes (the string starts with 直 instead).
--   direction:  'straight' when char 1 = 直, otherwise char 2
--                 (右 = right, 左 = left).
--   distance:   trailing digits before the 'm'.
--
-- SPEC (output columns):
--   course_id      integer
--   route_label    varchar   (the original course_name, kept for traceability)
--   surface        varchar   ('dirt' | 'turf' | 'steeplechase' | NULL)
--   direction      varchar   ('right' | 'left' | 'straight')
--   distance_m     integer
--
-- HINTS (DuckDB SQL):
--   substr(course_name, 1, 1)  -> first char
--   substr(course_name, 2, 1)  -> second char
--   case when ... then ... end -> decode chars (handle the 直 edge case!)
--   cast(regexp_extract(course_name, '([0-9]+)m', 1) as integer) -> distance
-- =============================================================================

with source as (
    select * from {{ ref('courses') }}
),

decoded as (
    select
        course_id,
        course_name as route_label,

        case
            when substr(course_name, 1, 1) = 'ダ' then 'dirt'
            when substr(course_name, 1, 1) = '芝' then 'turf'
            when substr(course_name, 1, 1) = '障' then 'steeplechase'
            else NULL
        end as surface,

        case
            when substr(course_name, 1, 1) = '直' then 'straight'
            when substr(course_name, 2, 1) = '右' then 'right'
            when substr(course_name, 2, 1) = '左' then 'left'
            else NULL
        end as direction,

        cast(regexp_extract(course_name, '([0-9]+)m', 1) as integer) as distance_m
    
    from source
)

select * from decoded
