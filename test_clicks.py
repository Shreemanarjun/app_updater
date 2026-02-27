import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page()
        await page.goto('http://localhost:8080/')
        await asyncio.sleep(2)
        
        # Check if body/div has 'dark' class
        dark = await page.evaluate('document.querySelector(".dark") !== null')
        if dark:
            print("Dark mode IS ACTIVE!")
        else:
            print("Dark mode NOT active.")

        await browser.close()

asyncio.run(main())
