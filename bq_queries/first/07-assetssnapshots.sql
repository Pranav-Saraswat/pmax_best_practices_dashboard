CREATE OR REPLACE TABLE `{bq_dataset}_bq.assetssnapshots_{date_iso}` AS
SELECT
  CURRENT_DATE()-1 as day,
  AGA.account_id,
  AGA.account_name,
  AGA.asset_group_id,
  AGA.asset_group_name,
  AGA.campaign_name,
  AGA.campaign_id,
  AGA.asset_id,
  AGA.asset_sub_type,
  AGA.asset_performance,
  A.text_asset_text,
  COALESCE(A.image_url,CONCAT('https://www.youtube.com/watch?v=',A.video_id)) AS image_video,
  COALESCE(A.image_url,CONCAT('https://i.ytimg.com/vi/', CONCAT(A.video_id, '/hqdefault.jpg'))) AS image_video_url
FROM {bq_dataset}.assetgroupasset AGA
JOIN {bq_dataset}.asset A USING(account_id,asset_id)
WHERE asset_performance NOT IN ('PENDING','UNKNOWN')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13