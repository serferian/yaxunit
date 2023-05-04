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

Функция Включен() Экспорт
	
	Возврат ЮТКонтекст.ДанныеКонтекста() <> Неопределено;
	
КонецФункции

Процедура УстановитьРежим(Режим) Экспорт
	
	Контекст = Настройки();
	Контекст.Режим = Режим;
	ОчиститьСлужебныеПараметры();
	
КонецПроцедуры

// Настройки.
// 
// Возвращаемое значение:
//  Структура - Настройки:
//  * Метод - Строка
//  * Реакция - Строка
//  * Настройки - Строка
//  * Перехват - Строка
//  * Режим - Строка - см. РежимыРаботы
//  * Статистика - Структура - Статистика вызовов:
//  	* Вызовы - Соответствие из Структура
//  * ПараметрыОбучения - Структура
//  * ПараметрыПроверки - Структура
Функция Настройки() Экспорт
	
	Настройки =  ЮТКонтекст.ЗначениеКонтекста(КлючНастроек());
	
	Если Настройки = Неопределено Тогда
		ВызватьИсключение "Что-то пошло не так, настройки Мокито не инициализированы";
	КонецЕсли;
	
	Возврат Настройки;
	
КонецФункции

#Область СтруктурыДанных

Функция РежимыРаботы() Экспорт
	
	Режимы = Новый Структура();
	Режимы.Вставить("Обучение", "Обучение");
	Режимы.Вставить("Тестирование", "Тестирование");
	Режимы.Вставить("Проверка", "Проверка");
	
	Возврат Новый ФиксированнаяСтруктура(Режимы);
	
КонецФункции

Функция ТипыДействийРеакций() Экспорт
	
	ТипыРеакций = Новый Структура();
	ТипыРеакций.Вставить("ВернутьРезультат", "ВернутьРезультат");
	ТипыРеакций.Вставить("ВыброситьИсключение", "ВыброситьИсключение");
	ТипыРеакций.Вставить("Пропустить", "Пропустить");
	ТипыРеакций.Вставить("ВызватьОсновнойМетод", "ВызватьОсновнойМетод");
	
	Возврат Новый ФиксированнаяСтруктура(ТипыРеакций);
	
КонецФункции

#КонецОбласти

Функция АнализВызова(Объект, ИмяМетода, ПараметрыМетода, ПрерватьВыполнение) Экспорт
	
	ПрерватьВыполнение = Ложь;
	
	Если НЕ Включен() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Настройки = Настройки();
	
	ПараметрыПерехвата = ДанныеПерехвата(Объект);
	
	Если ПараметрыПерехвата = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	РежимыРаботы = РежимыРаботы();
	
	СтруктураВызоваМетода = СтруктураВызоваМетода(Объект, ИмяМетода, ПараметрыМетода);
	
	Если Настройки.Режим = РежимыРаботы.Обучение ИЛИ Настройки.Режим = РежимыРаботы.Проверка Тогда
		
		ПрерватьВыполнение = Истина;
		Возврат СтруктураВызоваМетода;
		
	ИначеЕсли Настройки.Режим = РежимыРаботы.Тестирование Тогда
		
		ЗарегистрироватьВызовМетода(Настройки, ПараметрыПерехвата, СтруктураВызоваМетода);
		Возврат ПерехватитьВызовМетода(ПараметрыПерехвата, СтруктураВызоваМетода, ПрерватьВыполнение);
		
	КонецЕсли;
	
КонецФункции

// Структура вызова метода.
// 
// Параметры:
//  Объект - Произвольный - Объект, которому принадлежит метод
//  ИмяМетода - Строка - Имя вызванного метода
//  ПараметрыМетода - Массив из Произвольный - Набор параметров, с которыми был вызван метод
// 
// Возвращаемое значение:
//  Структура - Информация о вызове метода:
//   * Объект - Произвольный - Объект, которому принадлежит метод
//   * ИмяМетода - Строка - Имя вызванного метода
//   * Параметры - Массив из Произвольный - Набор параметров, с которыми был вызван метод
//   * Контекст - Строка - Контекст вызова метода
Функция СтруктураВызоваМетода(Объект, ИмяМетода, ПараметрыМетода) Экспорт
	
	Если ЭтоСтруктураВызоваМетода(Объект) Тогда
		Возврат Объект;
	КонецЕсли;
	
	СтруктураВызоваМетода = Новый Структура("Объект, ИмяМетода, Параметры", Объект, ИмяМетода, ПараметрыМетода);
	СтруктураВызоваМетода.Вставить("Контекст");
	
	Возврат СтруктураВызоваМетода;
	
КонецФункции

Функция ЭтоСтруктураВызоваМетода(Объект) Экспорт
	
	Возврат ТипЗнч(Объект) = Тип("Структура");
	
КонецФункции

#Область Предикаты

Функция ТипыУсловийПараметров() Экспорт
	
	Типы = Новый Структура;
	Типы.Вставить("Любой", "Любой");
	Типы.Вставить("Значение", "Значение");
	Типы.Вставить("Тип", "Тип");
	Типы.Вставить("ОписаниеТипа", "ОписаниеТипа");
	
	Возврат Новый ФиксированнаяСтруктура(Типы);
	
КонецФункции

// Описание маски параметра.
// 
// Параметры:
//  ТипУсловия - Строка - см. ТипыУсловийПараметров
//  Приоритет - Число - Приоритет маски
// 
// Возвращаемое значение:
//  Структура - Описание маски параметра:
// * МаскаСопоставленияПараметров - Булево - Признак, что это маска параметра
// * Режим - Строка - см. ТипыУсловийПараметров
// * Приоритет - Число - Приоритет маски, используется если значение подпадает под несколько масок, чем выше приоритет, тем лучше
Функция ОписаниеМаскиПараметра(ТипУсловия, Приоритет) Экспорт
	
	МаскаПараметра = Новый Структура("МаскаСопоставленияПараметров", Истина);
	МаскаПараметра.Вставить("Режим", ТипУсловия);
	МаскаПараметра.Вставить("Приоритет", Приоритет);
	
	Возврат МаскаПараметра;
	
КонецФункции

Функция ЭтоМаскаПарамера(Параметр) Экспорт
	
	Возврат ТипЗнч(Параметр) = Тип("Структура") И Параметр.Свойство("МаскаСопоставленияПараметров") И Параметр.МаскаСопоставленияПараметров;
	
КонецФункции

Функция ПроверитьПараметр(Параметр, Условие) Экспорт
	
	ТипыУсловий = ТипыУсловийПараметров();
	Совпадает = Ложь;
	
	Если Условие.Режим = ТипыУсловий.Любой Тогда
		
		Совпадает = Истина;
		
	ИначеЕсли Условие.Режим = ТипыУсловий.Значение Тогда
		
		Совпадает = ЮТСравнениеКлиентСервер.ЗначенияРавны(Условие.Значение, Параметр);
		
	ИначеЕсли Условие.Режим = ТипыУсловий.Тип Тогда
		
		Совпадает = Условие.Тип = ТипЗнч(Параметр);
		
	ИначеЕсли Условие.Режим = ТипыУсловий.ОписаниеТипа Тогда
		
		Совпадает = Условие.Тип.СодержитТип(ТипЗнч(Параметр));
		
	КонецЕсли;
	
	Возврат Совпадает;
		
КонецФункции

#КонецОбласти

#Область Перехват

Функция ПараметрыПерехвата() Экспорт
	
	Возврат Настройки().Перехват;
	
КонецФункции

// Данные перехвата.
// 
// Параметры:
//  Объект - Произвольный
// 
// Возвращаемое значение:
//  см. МокитоСлужебный.ОписаниеПараметровПерехватаОбъекта
Функция ДанныеПерехвата(Объект) Экспорт
	
	ПараметрыПерехвата = ПараметрыПерехвата();
	
	Если ТипЗнч(Объект) = Тип("Структура") Тогда
		Ключ = Объект.Объект;
	Иначе
		Ключ = Объект;
	КонецЕсли;
	
	ПараметрыПерехватаОбъекта = ПараметрыПерехвата[Ключ];
	
	Если ПараметрыПерехватаОбъекта = Неопределено И ЭтоОбъект(Ключ) Тогда
		ПараметрыПерехватаОбъекта = ПараметрыПерехвата[Ключ.Ссылка];
		
		Если ПараметрыПерехватаОбъекта = Неопределено Тогда
			
			ПолноеИмя = СтрРазделить(Ключ.Метаданные().ПолноеИмя(), ".");
			
			Менеджер = Новый(СтрШаблон("%1Менеджер.%2", ПолноеИмя[0], ПолноеИмя[1]));
			ПараметрыПерехватаОбъекта = ПараметрыПерехвата[Менеджер];
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат ПараметрыПерехватаОбъекта;
	
КонецФункции

Процедура ЗарегистрироватьПерехватОбъекта(Знач Объект) Экспорт
	
	Если ЭтоОбъект(Объект) Тогда
		Объект = Объект.Ссылка;
	КонецЕсли;
	
	ПараметрыПерехвата = ПараметрыПерехвата();
	ПараметрыПерехвата.Вставить(Объект, ОписаниеПараметровПерехватаОбъекта(Объект));
	
КонецПроцедуры

Функция ОписаниеПараметровПерехватаОбъекта(Объект) Экспорт
	
	Возврат Новый Структура("Объект, Методы", Объект, Новый Структура);
	
КонецФункции

#КонецОбласти

#Область Статистика

Функция СтатистикаВызовов(Знач Объект, ИмяМетода) Экспорт
	
	Если ЭтоОбъект(Объект) Тогда
		Объект = Объект.Ссылка;
	КонецЕсли;
	
	Статистика = Настройки().Статистика.Вызовы[Объект];
	
	Если Статистика = Неопределено ИЛИ НЕ Статистика.Свойство(ИмяМетода) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат Статистика[ИмяМетода];
	
КонецФункции

Процедура ОчиститьСтатистику() Экспорт
	
	Настройки = Настройки();
	Настройки.Статистика.Вызовы.Очистить();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ПередКаждымТестом(ОписаниеСобытия) Экспорт
	
	ИнициализироватьНастройки();
	
КонецПроцедуры

Процедура ПослеКаждогоТеста(ОписаниеСобытия) Экспорт
	
	ОчиститьНастройки();
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ОбработкаВызовов

// Зарегистрировать вызов метода.
// 
// Параметры:
//  Настройки - см. ИнициализироватьНастройки
//  ПараметрыПерехвата - см. ДанныеПерехвата
//  СтруктураВызоваМетода - см. СтруктураВызоваМетода
Процедура ЗарегистрироватьВызовМетода(Настройки, ПараметрыПерехвата, СтруктураВызоваМетода)
	
	Объект = ПараметрыПерехвата.Объект;
	ИмяМетода = СтруктураВызоваМетода.ИмяМетода;
	Статистика = Настройки.Статистика.Вызовы[Объект];
	
	Если Статистика = Неопределено Тогда
		
		Статистика = Новый Структура;
		Настройки.Статистика.Вызовы.Вставить(Объект, Статистика);
		
	КонецЕсли;
	
	Если НЕ Статистика.Свойство(ИмяМетода) Тогда
		
		Статистика.Вставить(ИмяМетода, Новый Массив);
		
	КонецЕсли;
	
	Статистика[ИмяМетода].Добавить(СтруктураВызоваМетода);
	
КонецПроцедуры

Функция ПерехватитьВызовМетода(ПараметрыПерехвата, СтруктураВызоваМетода, ПрерватьВыполнение)
	
	Если НЕ ПараметрыПерехвата.Методы.Свойство(СтруктураВызоваМетода.ИмяМетода) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ПараметрыПерехватаМетода = ПараметрыПерехвата.Методы[СтруктураВызоваМетода.ИмяМетода];
	
	Реакция = НайтиРеакцию(ПараметрыПерехватаМетода, СтруктураВызоваМетода);
	
	Если Реакция = Неопределено ИЛИ Реакция.Действие = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ПрерватьВыполнение = Истина;
	
	ТипыДействий = ТипыДействийРеакций();
	
	Если Реакция.Действие.ТипДействия = ТипыДействий.ВернутьРезультат Тогда
		
		Реакция.Действие.Обработано = Истина;
		Возврат Реакция.Действие.Результат;
		
	ИначеЕсли Реакция.Действие.ТипДействия = ТипыДействий.ВыброситьИсключение Тогда
		
		Реакция.Действие.Обработано = Истина;
		ВызватьИсключение Реакция.Действие.Ошибка;
		
	ИначеЕсли Реакция.Действие.ТипДействия = ТипыДействий.Пропустить Тогда
		
		Реакция.Действие.Обработано = Истина;
		Возврат Неопределено;
		
	ИначеЕсли Реакция.Действие.ТипДействия = ТипыДействий.ВызватьОсновнойМетод Тогда
		
		Реакция.Действие.Обработано = Истина;
		ПрерватьВыполнение = Ложь;
		
	Иначе
		
		ВызватьИсключение "Неизвестный тип действия реакции";
		
	КонецЕсли;
	
КонецФункции

#КонецОбласти

Функция НайтиРеакцию(ПараметрыПерехватаМетода, СтруктураВызоваМетода)
	
	ПараметрыВызова = СтруктураВызоваМетода.Параметры;
	
	ПриоритетыРеакций = Новый Массив();
	ЛучшийПриоритет = 0;
	
	Для Каждого Реакция Из ПараметрыПерехватаМетода.Реакции Цикл
		
		ПриоритетРеакции = ПроверитьРеакцию(Реакция, ПараметрыВызова);
		ПриоритетыРеакций.Добавить(Новый Структура("Приоритет, Реакция", ПриоритетРеакции, Реакция));
		
		Если ЛучшийПриоритет < ПриоритетРеакции Тогда
			ЛучшийПриоритет = ПриоритетРеакции;
		КонецЕсли;
		
	КонецЦикла;
	
	Реакция = Неопределено;
	Для Каждого ПриоритетРеакции Из ПриоритетыРеакций Цикл
		
		Если ПриоритетРеакции.Приоритет = ЛучшийПриоритет Тогда
			Реакция = ПриоритетРеакции.Реакция;
		Иначе
			Продолжить;
		КонецЕсли;
		
		Если Реакция.Действие <> Неопределено И НЕ Реакция.Действие.Обработано Тогда
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Реакция;
	
КонецФункции

Функция ПроверитьРеакцию(Реакция, ПараметрыМетода)
	
	Приоритет = 1;
	
	Если Реакция.УсловиеРеакции = Неопределено Тогда
		Возврат Приоритет;
	КонецЕсли;
	
	Для Инд = 0 По Реакция.УсловиеРеакции.ВГраница() Цикл
		
		Если НЕ ПроверитьПараметр(ПараметрыМетода[Инд], Реакция.УсловиеРеакции[Инд]) Тогда
			
			Возврат 0;
			
		КонецЕсли;
		
		Приоритет = Приоритет + Реакция.УсловиеРеакции[Инд].Приоритет;
		
	КонецЦикла;
		
	Возврат Приоритет;
	
КонецФункции

#Область Настройки

Процедура ИнициализироватьНастройки() Экспорт
	
	Настройки = Новый Структура;
	Настройки.Вставить("Метод");
	Настройки.Вставить("Реакция");
	Настройки.Вставить("Настройки");
	Настройки.Вставить("Перехват", Новый Соответствие);
	Настройки.Вставить("Режим", "НеУстановлен");
	Настройки.Вставить("Статистика", Новый Структура("Вызовы", Новый Соответствие));
	
	Настройки.Вставить("ПараметрыОбучения", Неопределено);
	Настройки.Вставить("ПараметрыПроверки", Неопределено);
	
	ЮТКонтекст.УстановитьЗначениеКонтекста(КлючНастроек(), Настройки, Истина);
	
КонецПроцедуры

Процедура ОчиститьНастройки() Экспорт
	
	ЮТКонтекст.УстановитьЗначениеКонтекста(КлючНастроек(), Неопределено);
	
КонецПроцедуры

Процедура СброситьПараметры() Экспорт
	
	ИнициализироватьНастройки();
	
КонецПроцедуры

Функция КлючНастроек()
	
	Возврат "Mockito";
	
КонецФункции

Процедура ОчиститьСлужебныеПараметры()
	
	Настройки = Настройки();
	
	Настройки.ПараметрыОбучения = Неопределено;
	Настройки.ПараметрыПроверки = Неопределено;
	
КонецПроцедуры

#КонецОбласти

Функция ЭтоСсылка(Значение) Экспорт
	
	Если Значение <> Неопределено Тогда
		
		ТипыСсылок = ЮТОбщий.ОписаниеТиповЛюбаяСсылка();
		Результат = ТипыСсылок.СодержитТип(ТипЗнч(Значение));
		
	Иначе
		
		Результат = Ложь;
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ЭтоОбъект(Значение) Экспорт
	
	Если Значение <> Неопределено И ЮТОбщий.ПеременнаяСодержитСвойство(Значение, "Ссылка") Тогда
		
		Возврат ЭтоСсылка(Значение.Ссылка);
		
	Иначе
		
		Результат = Ложь;
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти
