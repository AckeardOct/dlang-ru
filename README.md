<h1>Веб сайт для последователей Dlang.</h1>
<hr>
<h3>Как запустить?</h3>
<h2>Через docker:</h2>
<ol>
	<li>$ git clone https://github.com/AckeardOct/dlang-ru.git </li>
  <li>
  $ cd dlang-ru/db <br> 
  $ ./docker-start.sh # запуск postfix и mongodb
  $ ./add-admin-user-to-mongo.sh
  $ cd ../
  <li> $ dub </li>
</ol>
<h2>Без docker:</h2>
<h5>Нужно иметь mongo и mongo-tools, почтовый сервер (postfix)</h5>
<ol>
  <li>$ git clone https://github.com/AckeardOct/dlang-ru.git </li>
  <li>
  $ cd dlang-ru/db <br> 
  $ ./restart-db.sh #Это вернёт базу данных в минимальное состояние <br>
  $ cd ../
    </li> 
  <li> $ dub </li>
</ol>
<hr>
<h3>Что реализовано?</h3>
<ul>
  <li>Регистрация и вход пользователей
  	<ul>
  		<li> Вход админа admin admin </li>
  	</ul>
  </li>
  <li> HTTPS (сертификат не достоверный) </li>
  <li>Регистрация пользователей через email (сообщения уходят в спам)</li>  
  <li>Запуск серверных утилит через виртуализацию</li>
</ul>

<h3>Ближашие планы</h3>
<ul>
	<li>Единый конфигуратор</li>
	<li>Упростить запуск</li>
</ul>

<h5>Выслушаю любые предложения.</h5>
