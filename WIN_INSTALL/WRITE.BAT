:: This batch cmd is run as the final step in the installation of PAGE.
:: It creates the files page.bat and winpage.bat.

@>"..\page.bat" echo @start /min py "%%~dp0page.py" %%1 %%2 %%3
