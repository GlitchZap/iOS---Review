//
//  ScheduleSessionViewController.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 16/11/25.
//



import UIKit

class ScheduleSessionViewController: UIViewController {
    
    // MARK: - Properties
    var expert: Expert!
    private let dataManager = ExpertsDataManager.shared
    private let userDataManager = UserDataManager.shared
    
    private var availableTimeSlots: [TimeSlot] = []
    private var selectedDate: Date = Date()
    private var selectedTimeSlot: TimeSlot?
    
    private let calendar = Calendar.current
    private var currentMonth = Date()
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let sectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Schedule a Session"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let expertContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.06
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let expertImageView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.15)
        view.layer.cornerRadius = 25
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let expertInitialsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryPurple
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let expertNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let expertTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = ThemeManager.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Date & Time"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let monthYearLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let previousMonthButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = ThemeManager.Colors.primaryPurple
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nextMonthButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        button.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
        button.tintColor = ThemeManager.Colors.primaryPurple
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let weekdayStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let availableTimeSlotsLabel: UILabel = {
        let label = UILabel()
        label.text = "Available Time Slots"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeSlotsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm Session", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = ThemeManager.Colors.primaryPurple
        button.layer.cornerRadius = 28
        button.layer.shadowColor = ThemeManager.Colors.primaryPurple.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 8)
        button.layer.shadowRadius = 16
        button.layer.shadowOpacity = 0.4
        button.alpha = 0.5
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var calendarHeightConstraint: NSLayoutConstraint!
    private var timeSlotsHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        setupActions()
        setupCollectionViews()
        loadExpertData()
        updateCalendar()
        registerForThemeChanges()
    }
    
    private func registerForThemeChanges() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
                self.updateTheme()
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateTheme()
        }
    }
    
    private func updateTheme() {
        view.backgroundColor = ThemeManager.Colors.background
        sectionLabel.textColor = ThemeManager.Colors.primaryText
        expertContainer.backgroundColor = ThemeManager.Colors.cardBackground
        expertNameLabel.textColor = ThemeManager.Colors.primaryText
        expertTitleLabel.textColor = ThemeManager.Colors.secondaryText
        selectDateLabel.textColor = ThemeManager.Colors.primaryText
        monthYearLabel.textColor = ThemeManager.Colors.primaryText
        availableTimeSlotsLabel.textColor = ThemeManager.Colors.primaryText
        confirmButton.backgroundColor = ThemeManager.Colors.primaryPurple
        
        calendarCollectionView.reloadData()
        timeSlotsCollectionView.reloadData()
    }
    
    // MARK: - Setup Navigation Bar
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backTapped))
        backButton.tintColor = ThemeManager.Colors.primaryPurple
        navigationItem.leftBarButtonItem = backButton
        
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeTapped))
        closeButton.tintColor = ThemeManager.Colors.primaryPurple
        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func closeTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.Colors.background
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(sectionLabel)
        contentView.addSubview(expertContainer)
        expertContainer.addSubview(expertImageView)
        expertImageView.addSubview(expertInitialsLabel)
        expertContainer.addSubview(expertNameLabel)
        expertContainer.addSubview(expertTitleLabel)
        
        contentView.addSubview(selectDateLabel)
        contentView.addSubview(previousMonthButton)
        contentView.addSubview(monthYearLabel)
        contentView.addSubview(nextMonthButton)
        contentView.addSubview(weekdayStackView)
        contentView.addSubview(calendarCollectionView)
        contentView.addSubview(availableTimeSlotsLabel)
        contentView.addSubview(timeSlotsCollectionView)
        
        view.addSubview(confirmButton)
        
        // Setup weekday labels
        let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
        for weekday in weekdays {
            let label = UILabel()
            label.text = weekday
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            label.textColor = ThemeManager.Colors.secondaryText
            weekdayStackView.addArrangedSubview(label)
        }
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        calendarHeightConstraint = calendarCollectionView.heightAnchor.constraint(equalToConstant: 300)
        timeSlotsHeightConstraint = timeSlotsCollectionView.heightAnchor.constraint(equalToConstant: 200)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            sectionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            sectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            sectionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            expertContainer.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 20),
            expertContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            expertContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            expertContainer.heightAnchor.constraint(equalToConstant: 80),
            
            expertImageView.leadingAnchor.constraint(equalTo: expertContainer.leadingAnchor, constant: 16),
            expertImageView.centerYAnchor.constraint(equalTo: expertContainer.centerYAnchor),
            expertImageView.widthAnchor.constraint(equalToConstant: 50),
            expertImageView.heightAnchor.constraint(equalToConstant: 50),
            
            expertInitialsLabel.centerXAnchor.constraint(equalTo: expertImageView.centerXAnchor),
            expertInitialsLabel.centerYAnchor.constraint(equalTo: expertImageView.centerYAnchor),
            
            expertNameLabel.topAnchor.constraint(equalTo: expertImageView.topAnchor, constant: 6),
            expertNameLabel.leadingAnchor.constraint(equalTo: expertImageView.trailingAnchor, constant: 16),
            expertNameLabel.trailingAnchor.constraint(equalTo: expertContainer.trailingAnchor, constant: -16),
            
            expertTitleLabel.topAnchor.constraint(equalTo: expertNameLabel.bottomAnchor, constant: 4),
            expertTitleLabel.leadingAnchor.constraint(equalTo: expertNameLabel.leadingAnchor),
            expertTitleLabel.trailingAnchor.constraint(equalTo: expertNameLabel.trailingAnchor),
            
            selectDateLabel.topAnchor.constraint(equalTo: expertContainer.bottomAnchor, constant: 28),
            selectDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            selectDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            previousMonthButton.topAnchor.constraint(equalTo: selectDateLabel.bottomAnchor, constant: 20),
            previousMonthButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            previousMonthButton.widthAnchor.constraint(equalToConstant: 44),
            previousMonthButton.heightAnchor.constraint(equalToConstant: 44),
            
            monthYearLabel.centerYAnchor.constraint(equalTo: previousMonthButton.centerYAnchor),
            monthYearLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            nextMonthButton.centerYAnchor.constraint(equalTo: previousMonthButton.centerYAnchor),
            nextMonthButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            nextMonthButton.widthAnchor.constraint(equalToConstant: 44),
            nextMonthButton.heightAnchor.constraint(equalToConstant: 44),
            
            weekdayStackView.topAnchor.constraint(equalTo: monthYearLabel.bottomAnchor, constant: 20),
            weekdayStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            weekdayStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            weekdayStackView.heightAnchor.constraint(equalToConstant: 30),
            
            calendarCollectionView.topAnchor.constraint(equalTo: weekdayStackView.bottomAnchor, constant: 8),
            calendarCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            calendarCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            calendarHeightConstraint,
            
            availableTimeSlotsLabel.topAnchor.constraint(equalTo: calendarCollectionView.bottomAnchor, constant: 28),
            availableTimeSlotsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            availableTimeSlotsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            timeSlotsCollectionView.topAnchor.constraint(equalTo: availableTimeSlotsLabel.bottomAnchor, constant: 16),
            timeSlotsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            timeSlotsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            timeSlotsHeightConstraint,
            timeSlotsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: - Setup Collection Views
    
    private func setupCollectionViews() {
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        calendarCollectionView.register(CalendarDateCell.self, forCellWithReuseIdentifier: "CalendarDateCell")
        
        timeSlotsCollectionView.delegate = self
        timeSlotsCollectionView.dataSource = self
        timeSlotsCollectionView.register(TimeSlotCell.self, forCellWithReuseIdentifier: "TimeSlotCell")
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        previousMonthButton.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)
        nextMonthButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Load Data
    
    private func loadExpertData() {
        expertInitialsLabel.text = expert.initials
        expertNameLabel.text = expert.name
        expertTitleLabel.text = expert.title
    }
    
    private func updateCalendar() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        monthYearLabel.text = dateFormatter.string(from: currentMonth)
        
        calendarCollectionView.reloadData()
        
        // Update height based on number of weeks
        let numberOfWeeks = getNumberOfWeeksInMonth()
        let cellHeight: CGFloat = 44
        let spacing: CGFloat = 8
        calendarHeightConstraint.constant = CGFloat(numberOfWeeks) * (cellHeight + spacing) - spacing
        
        // Load time slots for selected date
        loadTimeSlots()
    }
    
    private func loadTimeSlots() {
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        availableTimeSlots = expert.availableTimeSlots.filter { slot in
            let slotStartOfDay = calendar.startOfDay(for: slot.date)
            return slotStartOfDay >= startOfDay && slotStartOfDay < endOfDay && slot.isAvailable
        }.sorted { $0.startTime < $1.startTime }
        
        timeSlotsCollectionView.reloadData()
        
        // Update height based on number of rows
        let itemsPerRow: CGFloat = 2
        let numberOfRows = ceil(CGFloat(availableTimeSlots.count) / itemsPerRow)
        let cellHeight: CGFloat = 50
        let spacing: CGFloat = 12
        let minHeight: CGFloat = 100
        timeSlotsHeightConstraint.constant = max(minHeight, numberOfRows * (cellHeight + spacing) - spacing)
        
        // Reset selected time slot if switching dates
        selectedTimeSlot = nil
        updateConfirmButton()
    }
    
    private func getNumberOfWeeksInMonth() -> Int {
        guard let range = calendar.range(of: .weekOfMonth, in: .month, for: currentMonth) else {
            return 5
        }
        return range.count
    }
    
    // MARK: - Actions
    
    @objc private func previousMonthTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        guard let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) else { return }
        currentMonth = newMonth
        updateCalendar()
    }
    
    @objc private func nextMonthTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        guard let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) else { return }
        currentMonth = newMonth
        updateCalendar()
    }
    
    @objc private func confirmButtonTapped() {
        guard let selectedTimeSlot = selectedTimeSlot,
              let currentUser = userDataManager.getCurrentUser() else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Schedule the session
        let session = dataManager.scheduleSession(
            expertId: expert.id,
            userId: currentUser.userId,
            timeSlot: selectedTimeSlot
        )
        
        // Navigate to confirmation screen
        let confirmationVC = SessionScheduledViewController()
        confirmationVC.session = session
        confirmationVC.expert = expert
        navigationController?.pushViewController(confirmationVC, animated: true)
    }
    
    private func updateConfirmButton() {
        let isEnabled = selectedTimeSlot != nil
        
        UIView.animate(withDuration: 0.3) {
            self.confirmButton.alpha = isEnabled ? 1.0 : 0.5
            self.confirmButton.isEnabled = isEnabled
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension ScheduleSessionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == calendarCollectionView {
            return getDaysInMonth()
        } else {
            return availableTimeSlots.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == calendarCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDateCell", for: indexPath) as! CalendarDateCell
            
            let day = getDayForIndexPath(indexPath)
            let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
            let isToday = calendar.isDateInToday(day)
            let isCurrentMonth = calendar.isDate(day, equalTo: currentMonth, toGranularity: .month)
            
            cell.configure(day: day, isSelected: isSelected, isToday: isToday, isCurrentMonth: isCurrentMonth)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeSlotCell", for: indexPath) as! TimeSlotCell
            
            let timeSlot = availableTimeSlots[indexPath.item]
            let isSelected = selectedTimeSlot?.id == timeSlot.id
            
            cell.configure(timeSlot: timeSlot, isSelected: isSelected)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        if collectionView == calendarCollectionView {
            let day = getDayForIndexPath(indexPath)
            
            // Only allow selecting future dates
            if day >= calendar.startOfDay(for: Date()) {
                selectedDate = day
                calendarCollectionView.reloadData()
                loadTimeSlots()
            }
        } else {
            selectedTimeSlot = availableTimeSlots[indexPath.item]
            timeSlotsCollectionView.reloadData()
            updateConfirmButton()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == calendarCollectionView {
            let width = (collectionView.bounds.width / 7) - 1
            return CGSize(width: width, height: 44)
        } else {
            let width = (collectionView.bounds.width - 12) / 2
            return CGSize(width: width, height: 50)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getDaysInMonth() -> Int {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth) else {
            return 30
        }
        
        guard let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return range.count
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let leadingDays = firstWeekday - 1
        
        return leadingDays + range.count
    }
    
    private func getDayForIndexPath(_ indexPath: IndexPath) -> Date {
        guard let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return Date()
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let leadingDays = firstWeekday - 1
        let dayOffset = indexPath.item - leadingDays
        
        guard let day = calendar.date(byAdding: .day, value: dayOffset, to: firstDay) else {
            return Date()
        }
        
        return day
    }
}

// MARK: - Calendar Date Cell

class CalendarDateCell: UICollectionViewCell {
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectionView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(selectionView)
        contentView.addSubview(dayLabel)
        
        NSLayoutConstraint.activate([
            selectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionView.widthAnchor.constraint(equalToConstant: 40),
            selectionView.heightAnchor.constraint(equalToConstant: 40),
            
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(day: Date, isSelected: Bool, isToday: Bool, isCurrentMonth: Bool) {
        let calendar = Calendar.current
        let dayNumber = calendar.component(.day, from: day)
        dayLabel.text = "\(dayNumber)"
        
        if isSelected {
            selectionView.backgroundColor = ThemeManager.Colors.primaryPurple
            dayLabel.textColor = .white
            dayLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        } else if isToday {
            selectionView.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.15)
            dayLabel.textColor = ThemeManager.Colors.primaryPurple
            dayLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        } else {
            selectionView.backgroundColor = .clear
            dayLabel.textColor = isCurrentMonth ? ThemeManager.Colors.primaryText : ThemeManager.Colors.tertiaryText
            dayLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        }
        
        // Disable past dates
        if day < calendar.startOfDay(for: Date()) {
            dayLabel.alpha = 0.3
        } else {
            dayLabel.alpha = 1.0
        }
    }
}

// MARK: - Time Slot Cell

class TimeSlotCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            timeLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    func configure(timeSlot: TimeSlot, isSelected: Bool) {
        timeLabel.text = timeSlot.displayTime
        
        if isSelected {
            containerView.backgroundColor = ThemeManager.Colors.primaryPurple
            containerView.layer.borderColor = ThemeManager.Colors.primaryPurple.cgColor
            timeLabel.textColor = .white
        } else {
            containerView.backgroundColor = ThemeManager.Colors.cardBackground
            containerView.layer.borderColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.3).cgColor
            timeLabel.textColor = ThemeManager.Colors.primaryPurple
        }
    }
}
