import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const port = process.env.PORT;
  const environment = process.env.NODE_ENV || 'development';
  const app = await NestFactory.create(AppModule);
  await app
    .listen(port)
    .then(() =>
      environment
        ? console.log('Server is running at url http://localhost:' + port)
        : null,
    );
}
bootstrap();
