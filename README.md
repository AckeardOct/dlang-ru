<h1>Веб сайт для последователей Dlang.</h1>
<hr>
<h3>Как запустить?</h3>
<h4>Необходим docker:</h2>
<ol>
	<li>$ git clone https://github.com/AckeardOct/dlang-ru.git </li>
  <li>
  $ cd dlang-ru/db <br> 
  $ ./docker-start.sh # запуск postfix и mongodb <br>
  $ cd ../
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
  <li>HTTPS (сертификат не достоверный)</li>
  <li>Регистрация пользователей через email (сообщения уходят в спам)</li>  
  <li>Запуск серверных утилит через виртуализацию docker</li>
  <li>Единый файл конфигурации cfg.json</li>
</ul>
<h5>Выслушаю любые предложения.</h5>
