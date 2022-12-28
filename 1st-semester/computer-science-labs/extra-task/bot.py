import time
import logging

from aiogram import Bot, Dispatcher, executor, types

BOT_TOKEN = "5960674208:AAGcW9pro3e1yDVloV--BiMcSCkj-OalVLQ"
REMINDER = "{}, вы выставили баллы в таблицу БАРС?"

bot = Bot(token=BOT_TOKEN)
dp = Dispatcher(bot=bot)



@dp.message_handler(commands=['start'])
async def start_handler(message: types.Message):
    user_id = message.from_user.id
    user_name = message.from_user.first_name
    user_full_name = message.from_user.full_name
    logging.info(f'{user_id=} {user_full_name=} {time.asctime()}')
    await message.reply(f"Здравствуйте, {user_full_name}")

@dp.message_handler(commands=['remind_me'])
async def start_handler(message: types.Message):
    user_id = message.from_user.id
    user_name = message.from_user.first_name
    user_full_name = message.from_user.full_name
    logging.info(f'{user_id=} {user_full_name=} {time.asctime()}')

    for i in range(7):
        await bot.send_message(user_id, REMINDER.format(user_name))
        time.sleep(60 * 60 * 24)

if __name__ == '__main__':
    executor.start_polling(dp)