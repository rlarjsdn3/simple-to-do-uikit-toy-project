//
//  ViewController.swift
//  SimpleTodoList
//
//  Created by 김건우 on 7/24/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    // NOTE: - lazy로 변수를 초기화해야 target이 nil이 아닌 뷰컨트롤러로
    //       - 올바르게 잡혀 doneButtonPressed 함수가 실행될 수 있습니다.
    
    private lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonPressed)
        )
        navigationItem.leftBarButtonItem = button
        return button
    }()
    
    var tasks: [Task] = [] {
        // 할 일 목록에 변화가 생길 때마다
        // UserDefaults에 할 일 목록을 저장
        didSet {
            saveTask()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 델리게이트 패턴 선언하기
        tableView.delegate = self
        tableView.dataSource = self
        // 저장된 할 일 목록 불러오기
        loadTask()
        // 테이블 뷰 스타일 설정하기
        tableView.rowHeight = 60.0
    }
    
    func saveTask() {
        // NOTE: - User Defaults는 앱의 간단한 설정값을 저정하기 위한 저장 시스템으로
        //       - Int, Double, Bool과 같은 간단한 데이터 타입을 저장하는 게 좋습니다.
        //       - 다만, 이번 프로젝트에서는 연습을 위해 크게 제약을 두지는 않았습니다.
        
        let userDefaults = UserDefaults.standard
        let dict = tasks.map {
            ["title": $0.title,
             "date": $0.date,
             "isCompleted": $0.isCompleted]
        }
        userDefaults.set(dict, forKey: "Tasks")
        
    }
    
    func loadTask() {
        let userDefaults = UserDefaults.standard
        guard let dict = userDefaults.object(forKey: "Tasks") as? [[String: Any]] else { return }
        self.tasks = dict.map {
            Task(
                title: $0["title"] as! String,
                date: $0["date"] as! Date,
                isCompleted: $0["isCompleted"] as! Bool
            )
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "오늘의 할 일은? 😻", message: "오늘 할 일을 적어주세요.", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            if let title = alert.textFields?[0].text {
                let task = Task(
                    title: title,
                    date: Date(),
                    isCompleted: false
                )
                self?.tasks.append(task)
                self?.tableView.reloadData()
            }
        }
        let cancelButton = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        alert.addTextField { tf in
            tf.placeholder = "할 일을 입력하세요."
        }
        
        present(alert, animated: true)
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        guard !self.tasks.isEmpty else { return }
        self.navigationItem.leftBarButtonItem = doneButton
        self.tableView.setEditing(true, animated: true)
    }
    
    @objc func doneButtonPressed() {
        print("DoneButtonPressed")
        self.navigationItem.leftBarButtonItem = editButton
        self.tableView.setEditing(false, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "TodoCell", for: indexPath) as? TodoCell {
            cell.titleLabel?.text = tasks[indexPath.row].title
            cell.dateLabel?.text = tasks[indexPath.row].date.formatted(date: .abbreviated, time: .omitted)
            cell.checkImage?.image = UIImage(systemName: tasks[indexPath.row].isCompleted ? "checkmark.circle" : "circle")
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tasks[indexPath.row].isCompleted.toggle()
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = tasks[sourceIndexPath.row]
        tasks.remove(at: sourceIndexPath.row)
        tasks.insert(temp, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        if tasks.isEmpty {
            doneButtonPressed()
        }
    }
}
