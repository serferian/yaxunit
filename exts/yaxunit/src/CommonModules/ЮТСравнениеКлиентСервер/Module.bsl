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

/////////////////////////////////////////////////////////////////////////////////
// Экспортные процедуры и функции для служебного использования внутри подсистемы
///////////////////////////////////////////////////////////////////////////////// 

#Область СлужебныйПрограммныйИнтерфейс

// Сравнивает данные сложной структуры с учетом вложенности.
//
// Параметры:
//  Данные1 - Структура
//          - ФиксированнаяСтруктура
//          - Соответствие из Произвольный
//          - ФиксированноеСоответствие из Произвольный
//          - Массив из Произвольный
//          - ФиксированныйМассив из Произвольный
//          - Строка
//          - Число
//          - Булево
//          - ТаблицаЗначений
//          - ХранилищеЗначения
//  Данные2 - Произвольный - те же типы, что и для параметра Данные1.
//  ПараметрыСравнения - Структура - Параметры проверки:
//                       * ГлубокийАнализ - Булево - Использовать сериализацию и прочие алгоритмы сравнения
// Возвращаемое значение:
//  Булево - Истина, если совпадают.
//
Функция ЗначенияРавны(Данные1, Данные2, ПараметрыСравнения = Неопределено) Экспорт
	
	ТипЗначения = ТипЗнч(Данные1);
	Если ТипЗначения <> ТипЗнч(Данные2) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если Данные1 = Данные2 Тогда
		Возврат Истина;
	КонецЕсли;
	
	Результат = Неопределено;
	
	Если ЭтоТипСтруктура(ТипЗначения) Тогда
		
		Результат = СтруктурыРавны(Данные1, Данные2);
		
	ИначеЕсли ЭтоТипСоответствие(ТипЗначения) Тогда
		
		Результат = СоответствияРавны(Данные1, Данные2);
		
	ИначеЕсли ЭтоТипМассива(ТипЗначения) Тогда
		
		Результат = МассивыРавны(Данные1, Данные2);
		
	ИначеЕсли ЭтоПримитивныйТип(ТипЗначения) ИЛИ ЮТОбщий.ОписаниеТиповЛюбаяСсылка().СодержитТип(ТипЗначения) Тогда
		// Возвращаем ложь, так как для этих типов должно сработать обычное равенство
		Результат = Ложь;
	КонецЕсли; // BSLLS:IfElseIfEndsWithElse-off
	
#Если Сервер Тогда
	Если ТипЗначения = Тип("ТаблицаЗначений") Тогда
		
		Результат = ЮТСравнениеСервер.ТаблицыРавны(Данные1, Данные2);
		
	ИначеЕсли ТипЗначения = Тип("ХранилищеЗначения") Тогда
		
		Результат = ЗначенияРавны(Данные1.Получить(), Данные2.Получить());
		
	КонецЕсли; // BSLLS:IfElseIfEndsWithElse-off
#КонецЕсли
	
	Если Результат = Неопределено И ПараметрыСравнения <> Неопределено И ЮТОбщий.ЗначениеСтруктуры(ПараметрыСравнения, "ГлубокийАнализ", Ложь) Тогда
		Результат = СравнитьПоЗначению(Данные1, Данные2);
	КонецЕсли;
	
	Если Результат = Неопределено Тогда
		Результат = Ложь;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Проверить равенство значений.
// 
// Параметры:
//  РезультатПроверки - см. ЮТФабрика.ОписаниеРезультатаПроверки
//  ПараметрыПроверки - см. ПараметрыПроверки
//  ПараметрыСравнения - Структура - Параметры проверки:
//                       * ГлубокийАнализ - Булево - Использовать сериализацию и прочие алгоритмы сравнения
Процедура ПроверитьРавенствоЗначений(РезультатПроверки, ПараметрыПроверки, ПараметрыСравнения) Экспорт
	
	ПроверяемоеЗначение = ПроверяемоеЗначение(ПараметрыПроверки);
	Результат = ЗначенияРавны(ПроверяемоеЗначение, ПараметрыПроверки.ОжидаемоеЗначение, ПараметрыСравнения);
	
	Реверс(Результат, ПараметрыПроверки);
	
	Если НЕ Результат Тогда
		ОбработатьРезультатСравнения(РезультатПроверки, ПараметрыПроверки, ПроверяемоеЗначение);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьНеравенство(РезультатПроверки, ПараметрыПроверки, Больше = Ложь, Меньше = Ложь, Равно = Ложь) Экспорт
	
	Результат = Ложь;
	ПроверяемоеЗначение = ПроверяемоеЗначение(ПараметрыПроверки);
	
	Если Больше Тогда
		Результат = ПроверяемоеЗначение > ПараметрыПроверки.ОжидаемоеЗначение;
	КонецЕсли;
	
	Если Меньше Тогда
		Результат = Результат ИЛИ ПроверяемоеЗначение < ПараметрыПроверки.ОжидаемоеЗначение;
	КонецЕсли;
	
	Если Равно Тогда
		Результат = Результат ИЛИ ПроверяемоеЗначение = ПараметрыПроверки.ОжидаемоеЗначение;
	КонецЕсли;
		
	Если НЕ Результат Тогда
		ОбработатьРезультатСравнения(РезультатПроверки, ПараметрыПроверки, ПроверяемоеЗначение);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьТипПараметра(РезультатПроверки, ПараметрыПроверки) Экспорт
	
	Если НЕ ПроверитьТипЗначения(РезультатПроверки, ПараметрыПроверки.ОжидаемоеЗначение, Новый ОписаниеТипов("ОписаниеТипов, Тип, Строка")) Тогда
		Возврат;
	КонецЕсли;
	
	ПроверяемоеЗначение = ПроверяемоеЗначение(ПараметрыПроверки);
	
	Результат = ТипЗначенияСоответствует(ПроверяемоеЗначение, ПараметрыПроверки.ОжидаемоеЗначение);
	
	Реверс(Результат, ПараметрыПроверки);
	
	Если НЕ Результат Тогда
		ОбработатьРезультатСравнения(РезультатПроверки, ПараметрыПроверки, ТипЗнч(ПроверяемоеЗначение));
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьНаличиеСвойства(РезультатПроверки, ПараметрыПроверки) Экспорт
	
	ПроверяемоеЗначение = ПроверяемоеЗначение(ПараметрыПроверки);
	Значение = ПроверяемоеЗначение;
	
	ПутьКСвойству = ЧастиПути(ПараметрыПроверки.ОжидаемоеЗначение);
	
	ПройденныйПуть = Новый Массив();
	
	Для Каждого Часть Из ПутьКСвойству Цикл
		
		ПройденныйПуть.Добавить(Часть);
		
		Если ТипЗнч(Значение) = Тип("ХранилищеЗначения") Тогда
			Значение = Значение.Получить();
		КонецЕсли;
		
		Попытка
			ЕстьСвойство = ЗначениеИмеетСвойство(Значение, Часть);
		Исключение
			ЕстьСвойство = Ложь;
		КонецПопытки;
		
		Если ЕстьСвойство Тогда
			Значение = Значение[Часть];
		Иначе
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	Успешно = ЕстьСвойство;
	Реверс(Успешно, ПараметрыПроверки);
	Если НЕ Успешно Тогда
		ОбработатьРезультатСравнения(РезультатПроверки, ПараметрыПроверки, ПроверяемоеЗначение);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьЗаполненность(РезультатПроверки, ПараметрыПроверки) Экспорт
	
	ПроверяемоеЗначение = ПроверяемоеЗначение(ПараметрыПроверки);
	Результат = ЗначениеЗаполнено(ПроверяемоеЗначение);
	
	Реверс(Результат, ПараметрыПроверки);
	
	Если НЕ Результат Тогда
		ОбработатьРезультатСравнения(РезультатПроверки, ПараметрыПроверки, ПроверяемоеЗначение);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьДлину(РезультатПроверки, ПараметрыПроверки) Экспорт
	
	Если НЕ ПроверитьТипЗначения(РезультатПроверки, ПараметрыПроверки.ОжидаемоеЗначение, "Число") Тогда
		Возврат;
	КонецЕсли;
	
	ПроверяемоеЗначение = ПроверяемоеЗначение(ПараметрыПроверки);
	ФактическаяДлина = ДлинаЗначения(ПроверяемоеЗначение);
	
	Если ФактическаяДлина = Неопределено Тогда
		ТекстОшибки = СтрШаблон("Тип проверяемого значения `%1` не обрабатывается утверждением", ТипЗнч(ПроверяемоеЗначение));
		ЮТРегистрацияОшибок.ДобавитьОшибкуКРезультатуПроверки(РезультатПроверки, ТекстОшибки);
		Возврат;
	КонецЕсли;
	
	Результат = ФактическаяДлина = ПараметрыПроверки.ОжидаемоеЗначение;
	Реверс(Результат, ПараметрыПроверки);
	
	Если НЕ Результат Тогда
		ОбработатьРезультатСравнения(РезультатПроверки, ПараметрыПроверки, ФактическаяДлина);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьСодержит(РезультатПроверки, ПараметрыПроверки) Экспорт
	
	ПроверяемоеЗначение = ПроверяемоеЗначение(ПараметрыПроверки);
	
	Результат = НайтиЗначение(ПроверяемоеЗначение, ПараметрыПроверки.ОжидаемоеЗначение);
	
	Если Результат = Неопределено Тогда
		ТекстОшибки = СтрШаблон("Тип проверяемого значения `%1` не обрабатывается утверждением", ТипЗнч(ПроверяемоеЗначение));
		ЮТРегистрацияОшибок.ДобавитьОшибкуКРезультатуПроверки(РезультатПроверки, ТекстОшибки);
		Возврат;
	КонецЕсли;
	
	Реверс(Результат, ПараметрыПроверки);
	
	Если НЕ Результат Тогда
		ОбработатьРезультатСравнения(РезультатПроверки, ПараметрыПроверки, ПроверяемоеЗначение);
	КонецЕсли;
	
КонецПроцедуры

Функция ПараметрыПроверки(ВидСравнения, ПроверяемоеЗначение, ИмяСвойства, ОжидаемоеЗначение, Реверс = Ложь) Экспорт
	
	Параметры = Новый Структура();
	Параметры.Вставить("ВидСравнения", ВидСравнения);
	Параметры.Вставить("ПроверяемоеЗначение", ПроверяемоеЗначение);
	Параметры.Вставить("ОжидаемоеЗначение", ОжидаемоеЗначение);
	Параметры.Вставить("ИмяСвойства", ИмяСвойства);
	Параметры.Вставить("Реверс", Реверс);
	
	Параметры.Вставить("ОбъектПроверки", Неопределено);
	Параметры.Вставить("ОписаниеПроверки", Неопределено);
	Параметры.Вставить("ПредставлениеПроверяемогоЗначения", Неопределено);
	
	Возврат Параметры;
	
КонецФункции

#КонецОбласти

/////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции, составляющие внутреннюю реализацию модуля 
///////////////////////////////////////////////////////////////////////////////// 
#Область СлужебныеПроцедурыИФункции

#Область Сравнения

Функция СтруктурыРавны(Данные1, Данные2)
	
	Если Данные1.Количество() <> Данные2.Количество() Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Для Каждого КлючИЗначение Из Данные1 Цикл
		СтароеЗначение = Неопределено;
		
		Если НЕ Данные2.Свойство(КлючИЗначение.Ключ, СтароеЗначение)
			ИЛИ НЕ ЗначенияРавны(КлючИЗначение.Значение, СтароеЗначение) Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Истина;
		
КонецФункции

Функция СоответствияРавны(Данные1, Данные2)
	
	Если Данные1.Количество() <> Данные2.Количество() Тогда
		Возврат Ложь;
	КонецЕсли;
	
	КлючиНовогоСоответствия = Новый Соответствие;
	
	Для Каждого КлючИЗначение Из Данные1 Цикл
		КлючиНовогоСоответствия.Вставить(КлючИЗначение.Ключ, Истина);
		СтароеЗначение = Данные2.Получить(КлючИЗначение.Ключ);
		
		Если НЕ ЗначенияРавны(КлючИЗначение.Значение, СтароеЗначение) Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого КлючИЗначение Из Данные2 Цикл
		Если КлючиНовогоСоответствия[КлючИЗначение.Ключ] = Неопределено Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Истина;
	
КонецФункции

Функция МассивыРавны(Данные1, Данные2)
	
	Если Данные1.Количество() <> Данные2.Количество() Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Для Индекс = 0 По Данные1.ВГраница() Цикл
		Если НЕ ЗначенияРавны(Данные1[Индекс], Данные2[Индекс]) Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Истина;
	
КонецФункции

Функция ПроверитьТипЗначения(РезультатПроверки,
							 Значение,
							 Знач ОжидаемыйТип,
							 Описание = "ожидаемого значения",
							 ЕслиУстановлен = Ложь,
							 Суффикс = Неопределено)
	
	Если ЕслиУстановлен И Значение = Неопределено Тогда
		Возврат Истина;
	КонецЕсли;
	
	Соответствует = ТипЗначенияСоответствует(Значение, ОжидаемыйТип);
	
	Если НЕ Соответствует Тогда
		ТекстОшибки = СтрШаблон("Не верный тип %1 (`%2`), должен быть `%3`%4",
								Описание,
								ТипЗнч(Значение),
								ОжидаемыйТип,
								Суффикс);
		ЮТРегистрацияОшибок.ДобавитьОшибкуКРезультатуПроверки(РезультатПроверки, ТекстОшибки);
	КонецЕсли;
	
	Возврат Соответствует;
	
КонецФункции

Функция ТипЗначенияСоответствует(Значение, ОжидаемыйТип)
	
	ТипОжидаемогоТипа = ТипЗнч(ОжидаемыйТип);
	
	Если ТипОжидаемогоТипа = Тип("Строка") Тогда
		Если СтрНайти(ОжидаемыйТип, ",") Тогда
			ОжидаемыйТип = Новый ОписаниеТипов(ОжидаемыйТип);
			ТипОжидаемогоТипа = Тип("ОписаниеТипов");
		Иначе
			ОжидаемыйТип = Тип(ОжидаемыйТип);
			ТипОжидаемогоТипа = Тип("Тип");
		КонецЕсли;
	КонецЕсли;
	
	ТипЗначения = ТипЗнч(Значение);
	
	Если ТипОжидаемогоТипа = Тип("ОписаниеТипов") Тогда
		// СодержитТип не подходит, всегда выдает истину если проверяем Тип("Неопределено")
		Соответствует = ОжидаемыйТип.Типы().Найти(ТипЗначения) <> Неопределено
			И ОжидаемыйТип.ПривестиЗначение(Значение) = Значение;
	Иначе
		Соответствует = ТипЗначения = ОжидаемыйТип;
	КонецЕсли;
	
	Возврат Соответствует;
	
КонецФункции

Функция СравнитьПоЗначению(Значение1, Значение2)
	
	Попытка
		СтрокаСравнения1 = ЮТОбщий.СтрокаJSON(Значение1);
		СтрокаСравнения2 = ЮТОбщий.СтрокаJSON(Значение2);
		Возврат СтрокаСравнения1 = СтрокаСравнения2;
	Исключение
		Возврат Ложь;
	КонецПопытки;
	
КонецФункции

#КонецОбласти

Функция ЧастиПути(Цепочка)
	
	ПутьКСвойству = Новый Массив();
	
	ТипПути = ТипЗнч(Цепочка);
	
	Если ТипПути = Тип("Строка") Тогда
		
		Части = СтрРазделить(Цепочка, ".");
		
		Для Каждого Часть Из Части Цикл
			
			Если СодержитИндекс(Часть) Тогда
				
				ИзвлечьИндекс(Часть, ПутьКСвойству);
				
			Иначе
				
				ПутьКСвойству.Добавить(Часть);
				
			КонецЕсли;
			
		КонецЦикла;
		
	Иначе
		
		ПутьКСвойству.Добавить(Цепочка);
		
	КонецЕсли; // BSLLS:IfElseIfEndsWithElse-off
	
	Возврат ПутьКСвойству;
	
КонецФункции

Функция СодержитИндекс(ИмяСвойства)
	
	Возврат СтрНайти(ИмяСвойства, "[") > 0 И СтрЗаканчиваетсяНа(ИмяСвойства, "]") ;
	
КонецФункции

Процедура ИзвлечьИндекс(ИмяСвойства, БлокиПути)
	
	ПозицияИндекса = СтрНайти(ИмяСвойства, "[");
	
	Если ПозицияИндекса > 1 Тогда
		БлокиПути.Добавить(Лев(ИмяСвойства, ПозицияИндекса - 1));
	КонецЕсли;
	
	Пока ПозицияИндекса > 0 Цикл
		
		ЗакрывающаяПозиция = СтрНайти(ИмяСвойства, "]", , ПозицияИндекса);
		ИндексСтрокой = Сред(ИмяСвойства, ПозицияИндекса + 1, ЗакрывающаяПозиция - ПозицияИндекса - 1);
		Индекс = Число(ИндексСтрокой);
		БлокиПути.Добавить(Индекс);
		
		ПозицияИндекса = СтрНайти(ИмяСвойства, "[", , ЗакрывающаяПозиция);
		
	КонецЦикла;
	
КонецПроцедуры

Функция ЗначениеИмеетСвойство(Значение, Свойство)
	
	Результат = Ложь;
	ТипЗначения = ТипЗнч(Значение);
	
	Если ТипЗначения = Тип("Структура") Или ТипЗначения = Тип("ФиксированнаяСтруктура") Тогда
		
		Результат = Значение.Свойство(Свойство);
		
	ИначеЕсли ТипЗначения = Тип("Соответствие") Или ТипЗначения = Тип("ФиксированноеСоответствие") Тогда
		
		Для Каждого КлючЗначение Из Значение Цикл
			
			Если КлючЗначение.Ключ = Свойство И ТипЗнч(КлючЗначение.Ключ) = ТипЗнч(Свойство) Тогда
				Результат = Истина;
				Прервать;
			КонецЕсли;
			
		КонецЦикла;
		
	ИначеЕсли ТипЗнч(Свойство) = Тип("Число") Тогда
		
		Если Свойство < 0 Тогда
			Свойство = Значение.Количество() + Свойство;
		КонецЕсли;
		Результат = Свойство >= 0 И Значение.Количество() > Свойство;
		
	Иначе
		
		Результат = ЮТОбщий.ПеременнаяСодержитСвойство(Значение, Свойство);
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Процедура ОбработатьРезультатСравнения(РезультатПроверки, ПараметрыПроверки, ФактическоеЗначение)
	
	ШаблонСообщения = ЮТПредикатыКлиентСервер.ШаблонВыражения(ПараметрыПроверки.ВидСравнения);
	
	Сообщение = СтрШаблон(ШаблонСообщения, ПараметрыПроверки.ОжидаемоеЗначение);
	
	Если ЗначениеЗаполнено(ПараметрыПроверки.ПредставлениеПроверяемогоЗначения) Тогда
		ПредставлениеЗначения = ПараметрыПроверки.ПредставлениеПроверяемогоЗначения;
	Иначе
		ПредставлениеЗначения = СтрШаблон("`%1`", ПараметрыПроверки.ПроверяемоеЗначение);
	КонецЕсли;
	
	ТекстОшибки = ЮТРегистрацияОшибок.ФорматированныйТекстОшибкиУтверждения(ПредставлениеЗначения,
																			Сообщение,
																			ПараметрыПроверки.ОбъектПроверки,
																		 	ПараметрыПроверки);
	
	ТекстОшибки = ЮТОбщий.ДобавитьСтроку(ПараметрыПроверки.ОписаниеПроверки, ТекстОшибки, ": ");
	ТекстОшибки = ВРег(Лев(ТекстОшибки, 1)) + Сред(ТекстОшибки, 2);
	ЮТРегистрацияОшибок.ДобавитьОшибкуСравненияКРезультатуПроверки(РезультатПроверки,
																   ТекстОшибки,
																   ФактическоеЗначение,
																   ПараметрыПроверки.ОжидаемоеЗначение);
	
КонецПроцедуры

// Параметры проверки.
// 
// Параметры:
//  ПараметрыПроверки - см. ПараметрыПроверки
// 
// Возвращаемое значение:
//  Произвольный
Функция ПроверяемоеЗначение(ПараметрыПроверки)
	
	Если ПараметрыПроверки.ИмяСвойства <> Неопределено Тогда
		Значение = ЗначениеСвойства(ПараметрыПроверки.ПроверяемоеЗначение, ПараметрыПроверки.ИмяСвойства);
	Иначе
		Значение = ПараметрыПроверки.ПроверяемоеЗначение;
	КонецЕсли;
	
	Возврат Значение;
	
КонецФункции

Функция ЗначениеСвойства(Объект, ИмяСвойства)
	
	Путь = ЧастиПути(ИмяСвойства);
	
	Значение = Объект;
	Для Каждого Часть Из Путь Цикл
		
		Если ТипЗнч(Значение) = Тип("ХранилищеЗначения") Тогда
			Значение = Значение.Получить();
		КонецЕсли;
		
		Если ТипЗнч(Часть) = Тип("Число") И Часть < 0 И ТипЗнч(Значение) <> Тип("Соответствие") Тогда
			Часть = Значение.Количество() + Часть;
		КонецЕсли;
		
		Значение = Значение[Часть];
		
	КонецЦикла;
	
	Возврат Значение;
	
КонецФункции

Процедура Реверс(Значение, ПараметрыПроверки)
	
	Если ПараметрыПроверки.Реверс Тогда
		Значение = НЕ Значение;
	КонецЕсли;
	
КонецПроцедуры

Функция ДлинаЗначения(ПроверяемоеЗначение)
	
	ТипПроверяемогоЗначения = ТипЗнч(ПроверяемоеЗначение);
	
	Если ТипПроверяемогоЗначения = Тип("Строка") Тогда
		
		ФактическаяДлина = СтрДлина(ПроверяемоеЗначение);
		
	Иначе
		
		Попытка
			ФактическаяДлина = ПроверяемоеЗначение.Количество();
		Исключение
			ФактическаяДлина = Неопределено;
		КонецПопытки;
		
	КонецЕсли;
	
	Возврат ФактическаяДлина;
	
КонецФункции

Функция НайтиЗначение(ПроверяемоеЗначение, ОжидаемоеЗначение)
	
	ТипПроверяемогоЗначения = ТипЗнч(ПроверяемоеЗначение);
	
	Если ТипПроверяемогоЗначения = Тип("Строка") Тогда
		
		ИскомоеЗначениеНайдено = СтрНайти(ПроверяемоеЗначение, ОжидаемоеЗначение) > 0;
		
	ИначеЕсли ЭтоТипМассива(ТипПроверяемогоЗначения) Тогда
		
		Индекс = ПроверяемоеЗначение.Найти(ОжидаемоеЗначение);
		ИскомоеЗначениеНайдено = Индекс <> Неопределено;
		
	ИначеЕсли ЭтоТипКлючЗначение(ТипПроверяемогоЗначения) Тогда
		
		ИскомоеЗначениеНайдено = Ложь;
		ТипОжидаемогоЗначения = ТипЗнч(ОжидаемоеЗначение);
		
		Для Каждого КлючЗначение Из ПроверяемоеЗначение Цикл
			Если КлючЗначение.Значение = ОжидаемоеЗначение И ТипЗнч(КлючЗначение.Значение) = ТипОжидаемогоЗначения Тогда
				ИскомоеЗначениеНайдено = Истина;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
	ИначеЕсли ТипПроверяемогоЗначения = Тип("СписокЗначений") Тогда
		
		ИскомоеЗначениеНайдено = ПроверяемоеЗначение.НайтиПоЗначению(ОжидаемоеЗначение) <> Неопределено;
		
	Иначе
		
		ИскомоеЗначениеНайдено = Неопределено; // Обрабатывается вызывающим методом
		
	КонецЕсли;
	
	Возврат ИскомоеЗначениеНайдено;
	
КонецФункции

Функция ЭтоТипМассива(Тип)
	
	Возврат Тип = Тип("Массив") Или Тип = Тип("ФиксированныйМассив");
	
КонецФункции

Функция ЭтоТипСтруктура(Тип)
	
	Возврат Тип = Тип("Структура") Или Тип = Тип("ФиксированнаяСтруктура");
	
КонецФункции

Функция ЭтоТипСоответствие(Тип)
	
	Возврат Тип = Тип("Соответствие") Или Тип = Тип("ФиксированноеСоответствие");
	
КонецФункции

Функция ЭтоТипКлючЗначение(Тип)
	
	Возврат ЭтоТипСтруктура(Тип) ИЛИ ЭтоТипСоответствие(Тип);
	
КонецФункции

Функция ЭтоПримитивныйТип(ТипЗначения)
	
	Возврат ТипЗначения = Тип("Число")
			ИЛИ ТипЗначения = Тип("Строка")
			ИЛИ ТипЗначения = Тип("Дата")
			ИЛИ ТипЗначения = Тип("Булево");
	
КонецФункции

#КонецОбласти
