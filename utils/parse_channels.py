"""
parse_channels.py
-----------------
Parses channel name strings into category, partner, and campaign columns.

Expected format: "category-partner_campaign"
Examples:
  "Search Engine-Hooli_Sedan"     -> category=Search Engine, partner=Hooli, campaign=Sedan
  "Finance Partnership-Debit Dharma" -> category=Finance Partnership, partner=Debit Dharma, campaign=Debit Dharma

If your channel names follow a different format, update the split logic below.
Adapt delimiter (default: '-' for category, '_' for campaign) to match your schema.
"""

def parse_channels(df, channel_col='channel'):
    """
    Parse a channel name column into category, partner, campaign.

    Parameters:
        df          : pandas DataFrame containing ad channel data
        channel_col : name of the column containing raw channel strings

    Returns:
        df with three new columns: category, partner, campaign
    """
    df = df.copy()

    # Split on '-' to get category and the rest
    df[['category', 'rest']] = df[channel_col].str.split('-', n=1, expand=True)

    # Split rest on '_' to get partner and campaign
    df[['partner', 'campaign']] = df['rest'].str.split('_', n=1, expand=True)

    # If no campaign segment, use partner as campaign
    df['campaign'] = df['campaign'].fillna(df['partner'])

    # Clean up
    df = df.drop(columns=['rest'])
    df['category'] = df['category'].str.strip()
    df['partner']  = df['partner'].str.strip()
    df['campaign'] = df['campaign'].str.strip()

    return df


# Usage in Jupyter:
# ad_channels = parse_channels(ad_channels)
# %sql --persist-replace ad_channels
