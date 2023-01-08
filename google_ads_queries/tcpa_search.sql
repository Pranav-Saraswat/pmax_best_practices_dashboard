# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


SELECT
  customer.id as account_id,
  campaign.id as campaign_id,
  segments.conversion_action~0 AS conversion_action_id,
  segments.conversion_action_name AS conversion_name,
  bidding_strategy.maximize_conversion_value.target_roas AS bidding_strategy_mcv_troas,
  bidding_strategy.target_roas.target_roas AS bidding_strategy_troas,
  bidding_strategy.maximize_conversions.target_cpa_micros AS bidding_strategy_mc_tcpa,
  bidding_strategy.target_cpa.target_cpa_micros AS bidding_strategy_tcpa,
  campaign.maximize_conversions.target_cpa_micros AS campaign_mc_tcpa,
  campaign.target_cpa.target_cpa_micros AS campaign_tcpa,
  campaign.maximize_conversion_value.target_roas AS campaign_mcv_troas,
  campaign.target_roas.target_roas AS campaign_troas
FROM
	campaign
WHERE
	campaign.advertising_channel_type = 'SEARCH'
