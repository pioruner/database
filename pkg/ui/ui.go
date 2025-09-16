package ui

import (
	"time"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/widget"
)

func UI_Call() {
	application := app.New()
	main_window := application.NewWindow("Main Control")
	main_window.Resize(fyne.NewSize(800, 400))
	message := widget.NewLabel("Welcome")
	button := widget.NewButton("Update", func() {
		formatted := time.Now().Format("Time: 03:04:05")
		message.SetText(formatted)
	})

	main_window.SetContent(container.NewVBox(message, button))
	main_window.ShowAndRun()
}
