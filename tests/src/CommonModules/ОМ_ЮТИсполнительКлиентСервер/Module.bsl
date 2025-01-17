//©///////////////////////////////////////////////////////////////////////////©//
//
//  Copyright 2021-2024 BIA-Technologies Limited Liability Company
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
		.ДобавитьТест("ЛомающийКонтекстТест").ВТранзакции()
		.ДобавитьТест("ПроверкаТранзакции")
			.СПараметрами(Ложь)
			.СПараметрами(Истина).ВТранзакции()
	;
		
КонецПроцедуры

Процедура ЛомающийКонтекстТест() Экспорт
	
	ЮТест.ОжидаетЧто(ЮТКонтекст.ДанныеКонтекста())
		.ЭтоНеНеопределено();
	
	НачатьТранзакцию();
	Попытка
		Справочники.Встречи.СоздатьЭлемент().Записать();
		ЗафиксироватьТранзакцию();
	Исключение
		ОбновитьПовторноИспользуемыеЗначения();
		Если ЮТКонтекст.ДанныеКонтекста() <> Неопределено Тогда
			ВызватьИсключение "Контекст не сломан";
		КонецЕсли;
		ОтменитьТранзакцию();
	КонецПопытки;
	
КонецПроцедуры

Процедура ПроверкаТранзакции(АктивностьТранзакции) Экспорт
	
	ЮТест.ОжидаетЧто(ТранзакцияАктивна(), "ТранзакцияАктивна")
		.Равно(АктивностьТранзакции);
	
КонецПроцедуры

#КонецОбласти
