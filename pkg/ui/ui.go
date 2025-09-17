package ui

import (
	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/dialog"
	"fyne.io/fyne/v2/layout"
	"fyne.io/fyne/v2/theme"
	"fyne.io/fyne/v2/widget"
)

type Item struct {
	Title       string
	Description string
}
type appStruct struct {
	top    *fyne.Container
	mid    *fyne.Container
	bottom *fyne.Container
}

var appParts appStruct

func top(parent fyne.Window) {
	items := []string{"COM1", "COM2", "COM3"}
	enum := widget.NewSelect(items, func(string) {})
	enum.SetSelectedIndex(0)
	file := widget.NewLabel("Выберете порт...")
	file.Wrapping = fyne.TextWrapOff
	file.Truncation = fyne.TextTruncateClip

	selectFileB := widget.NewButtonWithIcon("Connect", theme.SearchIcon(), func() {
		dialog.NewFileOpen(func(reader fyne.URIReadCloser, err error) {
			if err != nil {
				dialog.ShowError(err, parent)
				return
			}
			if reader == nil {
				return
			}
			defer func(reader fyne.URIReadCloser) {
				err := reader.Close()
				if err != nil {

				}
			}(reader)
			file.SetText(reader.URI().String())
		}, parent).Show()
	})
	appParts.top = container.NewStack(widget.NewCard("", "", container.NewBorder(nil, nil, nil, selectFileB, enum)))
}

func mid() {
	// ----- mid -----
	items := []Item{
		{"Первый", "Описание первого"},
		{"Второй", "Описание второго"},
		{"Третий", "Описание третьего"},
	}
	card := widget.NewCard("Выберите элемент", "", nil)

	list := widget.NewList(
		func() int { return len(items) },
		func() fyne.CanvasObject { return widget.NewLabel("") },
		func(i widget.ListItemID, o fyne.CanvasObject) {
			o.(*widget.Label).SetText(items[i].Title)
		},
	)

	list.OnSelected = func(id widget.ListItemID) {
		card.SetTitle(items[id].Title)
		card.SetSubTitle(items[id].Description)
		card.SetContent(widget.NewLabel("Тут может быть ещё контент"))
	}

	midContent := container.NewHSplit(list, card)
	midContent.Offset = 0.3
	appParts.mid = container.NewStack(widget.NewCard("", "", midContent))
}

func bottom() {
	filterEntry := widget.NewEntry()
	filterEntry.SetPlaceHolder("Введите фильтр...")
	searchBtn := widget.NewButton("Искать", func() {})
	resetBtn := widget.NewButton("Сброс", func() {})
	appParts.bottom = container.NewBorder(
		nil, nil, nil, // top, bottom, left
		container.NewHBox(searchBtn, resetBtn), // right
		container.NewStack(filterEntry),        // center (растягивается)
	)
}

func UI_Call() {
	mainApp := app.New()
	mainWindow := mainApp.NewWindow("База образцов")
	mainWindow.SetIcon(theme.InfoIcon())
	mainWindow.Resize(fyne.NewSize(800, 600))
	top(mainWindow)
	mid()
	bottom()
	mainWindow.SetContent(container.New(
		layout.NewBorderLayout(appParts.top, appParts.bottom, nil, nil),
		appParts.top,
		appParts.mid,
		appParts.bottom))
	mainWindow.ShowAndRun()
}
