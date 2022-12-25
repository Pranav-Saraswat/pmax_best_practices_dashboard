CREATE OR REPLACE VIEW `{bq_dataset}_bq.assetgroupbestpractices` AS
WITH video_data AS (
  SELECT
    account_id,
    account_name,
    campaign_id,
    campaign_name,
    asset_group_id,
    asset_group_name,
    ad_strength,
    is_video_uploaded,
    CAST(1 as FLOAT64) AS video_score
  FROM `{bq_dataset}_bq.video_assets`
),
text_data AS (
  SELECT
    account_id,
    account_name,
    campaign_id,
    campaign_name,
    asset_group_id,
    count_descriptions,
    count_headlines,
    count_long_headlines,
    count_short_descriptions,
    count_short_headlines,
    (IF(count_descriptions >= 5,1,0)+IF(count_headlines >= 5,1,0)+IF(count_long_headlines >= 1,1,0)+IF(count_short_descriptions >= 1,1,0)+IF(count_short_headlines >= 1,1,0))/5 AS text_score
  FROM `{bq_dataset}_bq.text_assets`
),
image_data AS (
  SELECT
    account_id,
    account_name,
    campaign_id,
    campaign_name,
    asset_group_id,
    count_images,
    count_logos,
    count_rectangular,
    count_rectangular_logos,
    count_square,
    count_square_logos,
    (IF(count_images >= 15,1,0)+IF(count_logos >= 5,1,0)+IF(count_rectangular >= 1,1,0)+IF(count_rectangular_logos >= 1,1,0)+IF(count_square >= 1,1,0)+IF(count_square_logos >= 1,1,0))/6 AS image_score
  FROM `{bq_dataset}_bq.image_assets`
)
SELECT
    AGS.account_id,
    AGS.account_name,
    AGS.campaign_id,
    AGS.campaign_name,  
    AGS.asset_group_id,
    AGS.asset_group_name,
    AGS.ad_strength,
    V.is_video_uploaded,
    IF(T.count_descriptions = 5,"Yes","X") AS count_descriptions,
    IF(T.count_headlines = 5,"Yes","X") AS count_headlines,
    IF(T.count_long_headlines >= 1,"Yes","X") AS count_long_headlines,
    IF(T.count_short_descriptions >= 1,"Yes","X") AS count_short_descriptions,
    IF(T.count_short_headlines >= 1,"Yes","X") AS count_short_headlines,
    IF(I.count_images BETWEEN 15 AND 20,"Yes","X") AS count_images,
    IF(I.count_logos = 5,"Yes","X") AS count_logos,
    IF(I.count_rectangular >= 1,"Yes","X") AS count_rectangular,
    IF(I.count_rectangular_logos >= 1,"Yes","X") AS count_rectangular_logos,
    IF(I.count_square >= 1,"Yes","X") AS count_square,
    IF(I.count_square_logos >= 1,"Yes","X") AS count_square_logos,
    V.video_score,
    T.text_score,
    I.image_score,
    (IF(count_descriptions<5,5-count_descriptions,0) + IF(count_headlines<5,5-count_headlines,0) + IF(count_long_headlines>=1,1,0) + IF(count_short_descriptions>=1,1,0) + IF(count_short_headlines>=1,1,0) + IF(count_images<15,15-count_images,0) + IF(count_logos<5,5-count_logos,0) + IF(count_rectangular>=1,1,0) + IF(count_square>=1,1,0) + IF(count_square_logos>=1,1,0)) AS num_missing_assets
FROM `{bq_dataset}.assetgroupsummary` AGS
JOIN video_data V USING (account_id, campaign_id, asset_group_id)
JOIN text_data T USING (account_id,campaign_id, asset_group_id)
JOIN image_data I USING (account_id,campaign_id, asset_group_id)