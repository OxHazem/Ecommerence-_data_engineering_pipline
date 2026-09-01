# # # Data_generator/exchange_rate/api_client.py

# # from datetime import date
# # from decimal import Decimal

# # import requests

# # from .config import API_BASE_URL, API_TIMEOUT


# # class ExchangeRateAPIClient:
# #     """
# #     Client for the Frankfurter Exchange Rate API.
# #     """

# #     def __init__(
# #         self,
# #         base_url=API_BASE_URL,
# #         timeout=API_TIMEOUT
# #     ):
# #         self.base_url = base_url.rstrip("/")
# #         self.timeout = timeout

# #     def get_rate(
# #         self,
# #         from_currency,
# #         to_currency,
# #         rate_date=None
# #     ):
# #         """
# #         Get an exchange rate between two currencies.

# #         Parameters
# #         ----------
# #         from_currency : str
# #             Source currency, e.g. SAR.

# #         to_currency : str
# #             Target currency, e.g. EGP.

# #         rate_date : str or datetime.date, optional
# #             Historical date in YYYY-MM-DD format.

# #         Returns
# #         -------
# #         dict
# #             Exchange-rate information.
# #         """

# #         from_currency = from_currency.upper()
# #         to_currency = to_currency.upper()

# #         url = (
# #             f"{self.base_url}/rate/"
# #             f"{from_currency}/{to_currency}"
# #         )

# #         params = {}

# #         if rate_date is not None:

# #             if isinstance(rate_date, date):
# #                 rate_date = rate_date.isoformat()

# #             params["date"] = rate_date

# #         response = requests.get(
# #             url,
# #             params=params,
# #             timeout=self.timeout
# #         )

# #         response.raise_for_status()

# #         data = response.json()

# #         return {
# #             "date": data["date"],
# #             "base": data["base"],
# #             "quote": data["quote"],
# #             "rate": Decimal(str(data["rate"]))
# #         }



# # Data_generator/exchange_rate/api_client.py

# from datetime import date
# from decimal import Decimal

# import requests

# from .config import API_BASE_URL, API_TIMEOUT


# class ExchangeRateAPIClient:
#     """
#     Client for the Frankfurter Exchange Rate API.
#     """

#     def __init__(
#         self,
#         base_url=API_BASE_URL,
#         timeout=API_TIMEOUT
#     ):
#         self.base_url = base_url.rstrip("/")
#         self.timeout = timeout

#     def get_rate(
#         self,
#         from_currency,
#         to_currency,
#         rate_date=None
#     ):
#         """
#         Get an exchange rate between two currencies.
#         """

#         from_currency = from_currency.upper()
#         to_currency = to_currency.upper()

#         url = (
#             f"{self.base_url}/rate/"
#             f"{from_currency}/{to_currency}"
#         )

#         params = {}

#         if rate_date is not None:

#             if isinstance(rate_date, date):
#                 rate_date = rate_date.isoformat()

#             params["date"] = rate_date

#         response = requests.get(
#             url,
#             params=params,
#             timeout=self.timeout
#         )

#         response.raise_for_status()

#         data = response.json()

#         return {
#             "date": data["date"],
#             "base": data["base"],
#             "quote": data["quote"],
#             "rate": Decimal(str(data["rate"]))
#         }

#     def get_historical_rates(
#         self,
#         from_currency,
#         to_currency,
#         start_date,
#         end_date
#     ):
#         """
#         Get historical exchange rates over a date range.
#         """

#         from_currency = from_currency.upper()
#         to_currency = to_currency.upper()

#         if isinstance(start_date, date):
#             start_date = start_date.isoformat()

#         if isinstance(end_date, date):
#             end_date = end_date.isoformat()

#         url = f"{self.base_url}/rates"

#         params = {
#             "base": from_currency,
#             "quotes": to_currency,
#             "from": start_date,
#             "to": end_date,
#         }

#         response = requests.get(
#             url,
#             params=params,
#             timeout=self.timeout
#         )

#         response.raise_for_status()

#         data = response.json()

#         records = []

#         for row in data:

#             records.append({
#                 "date": row["date"],
#                 "base": row["base"],
#                 "quote": to_currency,
#                 "rate": Decimal(str(row[to_currency]))
#             })

#         return records

from datetime import date
from decimal import Decimal

import requests

from .config import API_BASE_URL, API_TIMEOUT


class ExchangeRateAPIClient:
    """
    Client for the Frankfurter Exchange Rate API.
    """

    def __init__(
        self,
        base_url=API_BASE_URL,
        timeout=API_TIMEOUT
    ):
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout

    # ========================================================
    # SINGLE DATE
    # ========================================================

    def get_rate(
        self,
        from_currency,
        to_currency,
        rate_date=None
    ):
        """
        Get an exchange rate between two currencies
        for one specific date.
        """

        from_currency = from_currency.upper()
        to_currency = to_currency.upper()

        url = (
            f"{self.base_url}/rate/"
            f"{from_currency}/{to_currency}"
        )

        params = {}

        if rate_date is not None:

            if isinstance(rate_date, date):
                rate_date = rate_date.isoformat()

            params["date"] = rate_date

        response = requests.get(
            url,
            params=params,
            timeout=self.timeout
        )

        response.raise_for_status()

        data = response.json()

        return {
            "date": data["date"],
            "base": data["base"],
            "quote": data["quote"],
            "rate": Decimal(
                str(data["rate"])
            )
        }

    # ========================================================
    # HISTORICAL DATE RANGE
    # ========================================================

    def get_historical_rates(
        self,
        from_currency,
        to_currency,
        start_date,
        end_date
    ):
        """
        Get historical exchange rates over a date range.
        """

        from_currency = from_currency.upper()
        to_currency = to_currency.upper()

        if isinstance(start_date, date):
            start_date = start_date.isoformat()

        if isinstance(end_date, date):
            end_date = end_date.isoformat()

        url = f"{self.base_url}/rates"

        params = {
            "base": from_currency,
            "quotes": to_currency,
            "from": start_date,
            "to": end_date,
        }

        response = requests.get(
            url,
            params=params,
            timeout=self.timeout
        )

        response.raise_for_status()

        data = response.json()

        records = []

        for row in data:

            records.append({
                "date": row["date"],
                "base": row["base"],
                "quote": row["quote"],
                "rate": Decimal(
                    str(row["rate"])
                )
            })

        return records