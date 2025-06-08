WITH cte AS (
    SELECT  player_id,
            SUM(score) AS score
    FROM (
        SELECT  first_player AS player_id,
                first_score AS score
        FROM matches
        UNION ALL
        SELECT  second_player AS player_id,
                second_score AS score
        FROM matches
    ) a
    GROUP BY player_id
)
SELECT  group_id,
        player_id
FROM (
    SELECT  p.group_id,
            c.player_id,
            c.score,
            ROW_NUMBER() OVER(PARTITION BY p.group_id ORDER BY c.score DESC, c.player_id) rwn
            -- order by score desc first so that we consider the max scored player, and then sorting by player_id ascending so that we capture the lowest player_id in case of a tie.
    FROM players p
    JOIN cte c
    ON p.player_id = c.player_id
) a
WHERE rwn = 1;