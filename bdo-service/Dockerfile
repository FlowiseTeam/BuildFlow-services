FROM python:3.12-slim

WORKDIR /usr/src/app

COPY . .

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 3000

ENV NAME World

CMD ["uvicorn", "src.app:app", "--host", "0.0.0.0", "--port", "3000"]
