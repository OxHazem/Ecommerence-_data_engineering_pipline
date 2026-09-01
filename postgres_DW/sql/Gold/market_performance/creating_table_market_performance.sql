DROP TABLE IF EXISTS gold.marketing_performance;

CREATE TABLE gold.marketing_performance (

    campaign_name VARCHAR(100) NOT NULL,

    channel VARCHAR(30) NOT NULL,

    events INTEGER NOT NULL,

    unique_customers INTEGER NOT NULL,

    impressions INTEGER NOT NULL,

    views INTEGER NOT NULL,

    clicks INTEGER NOT NULL,

    add_to_carts INTEGER NOT NULL,

    purchases INTEGER NOT NULL,

    PRIMARY KEY (
        campaign_name,
        channel
    )

);