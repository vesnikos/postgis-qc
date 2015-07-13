with poly as (select ST_GeomFromGeoJSON ('
{
        "type": "Polygon",
        "coordinates": [
          [
            [
              22.028961181640625,
              39.863371338285305
            ],
            [
              22.1429443359375,
              40.348637376031725
            ],
            [
              22.169036865234375,
              40.348637376031725
            ],
            [
              22.048187255859375,
              39.868641655580646
            ],
            [
              22.028961181640625,
              39.863371338285305
            ]
          ]
        ]
      }
') geom
    )
,


init_solution as (
--first solution x using leastSqr
select  slope_r as init_slope from
poly
, (select  atan(regr_slope(st_x(geom),st_y(geom))) slope_r from (select (ST_DumpPoints(geom)).geom geom from poly) foo ) rot
)
-- pick best solution in x-0.05 < s < x+0.05
select 1 id
, degrees(rot.ation)
, st_xmax(bbox)-st_xmin(bbox) a_axis
, st_ymax(bbox)-st_ymin(bbox) b_axis
, bbox
from
(select (generate_series( ((init_slope-0.05)*1000)::integer,(((init_slope+0.05)*1000))::int,1)::numeric/1000) ation from init_solution ) rot
, poly
, init_solution
, lateral st_rotate(poly.geom,rot.ation,st_centroid(poly.geom)) shape_t
, lateral st_envelope(shape_t) bbox_t
, lateral st_rotate(bbox_t,-rot.ation,st_centroid(poly.geom)) bbox
order by a_axis asc limit 1;


