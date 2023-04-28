//©///////////////////////////////////////////////////////////////////////////©//
//
//  Copyright 2021-2023 BIA-Technologies Limited Liability Company
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//©///////////////////////////////////////////////////////////////////////////©//

#Область СлужебныйПрограммныйИнтерфейс

Процедура ИсполняемыеСценарии() Экспорт
	
	ЮТТесты
		.ДобавитьТест("Пропустить")
		.ДобавитьТест("ПроверкаКонтекста")
	;
	
КонецПроцедуры

Процедура ПередВсемиТестами() Экспорт
	
	ЮТест.Контекст().УстановитьЗначение("Глобальный", 1);
	ЮТест.Контекст().УстановитьЗначение("Заменяемый", 5);
	ЮТест.Контекст().УстановитьЗначение("Коллекция", Новый Массив());
	ЮТест.Контекст().Значение("Коллекция").Добавить("ПередВсемиТестами");
	
КонецПроцедуры

Процедура ПередТестовымНабором() Экспорт
	
	ЮТест.Контекст().УстановитьЗначение("Набор", 2);
	ЮТест.Контекст().Значение("Коллекция").Добавить("ПередТестовымНабором");
	
КонецПроцедуры

Процедура ПередКаждымТестом() Экспорт
	
	ЮТест.Контекст().УстановитьЗначение("Тест", 3);
	ЮТест.Контекст().УстановитьЗначение("Заменяемый", 3);
	ЮТест.Контекст().Значение("Коллекция").Добавить("ПередКаждымТестом");
	
КонецПроцедуры

Процедура ПослеКаждогоТеста() Экспорт
	
	ЮТест.Контекст().Значение("Коллекция").Добавить("ПослеКаждогоТеста");
	
КонецПроцедуры

Процедура ПослеТестовогоНабора() Экспорт
	
	ЮТест.Контекст().Значение("Коллекция").Добавить("ПослеТестовогоНабора");
	
КонецПроцедуры

Процедура ПослеВсехТестов() Экспорт
	
	ЮТест.Контекст().Значение("Коллекция").Добавить("ПослеВсехТестов");
	ЮТест.ОжидаетЧто(ЮТест.Контекст().Значение("Коллекция")).ИмеетДлину(8);
	
КонецПроцедуры

Процедура Пропустить() Экспорт
	
	ЮТест.Пропустить();
	ВызватьИсключение "Не отработал пропуск теста";
	
КонецПроцедуры

Процедура ПроверкаКонтекста() Экспорт
	
	ЮТест.ОжидаетЧто(ЮТест.Контекст().Значение("Глобальный"), "Значение глобального контекста").Равно(1);
	ЮТест.ОжидаетЧто(ЮТест.Контекст().Значение("Набор"), "Значение контекста набора").Равно(2);
	ЮТест.ОжидаетЧто(ЮТест.Контекст().Значение("Тест"), "Значение контекста теста").Равно(3);
	ЮТест.ОжидаетЧто(ЮТест.Контекст().Значение("Заменяемый"), "Замененное значение контекста").Равно(3);
	ЮТест.ОжидаетЧто(ЮТест.Контекст().Значение("Коллекция"))
		.ИмеетДлинуБольше(2)
		.Содержит("ПередВсемиТестами")
		.Содержит("ПередТестовымНабором")
		.Содержит("ПередКаждымТестом");

КонецПроцедуры

#КонецОбласти

