## Navigation

If you want to navigate to ordinary screen like this [Settings Screen](https://www.figma.com/file/CUsLK0bK6InPcslLHzul7d/Datadash?node-id=5720%3A163929)

```dart
Navigator.of(context).push(
  route(const SettingsPage()),
);
```

For screens opened from bottom to top with layer like this [Bond Details](https://www.figma.com/file/CUsLK0bK6InPcslLHzul7d/Datadash?node-id=14853%3A57865)

```dart
Navigator.of(context).push(
  route.featureDialog(BondInfoPage(btcBondInfo)),
);
```

Screens like this you have to open only after opening route.featureDialog() [Select Language](https://www.figma.com/file/CUsLK0bK6InPcslLHzul7d/Datadash?node-id=972%3A17441)

```dart
Navigator.of(context).push(
  route.featureDialogPage(const LanguagePage()),
);
```

To close FeatureDialog screens, you need to call

```dart
BottomFlowDialog.of(context).close();
```

instead of

```dart
Navigator.of(context).pop();
```

Also this is handled automatically inside `MxcAppBar.back`, `MxcAppBar.close` and `MxcAppBar.backAndClose` or you can use `appBarPopHandlerBuilder` and `appBarCloseHandlerBuilder` manually

