import SwiftUI
import CellsReloadable

class ViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .grouped)
    lazy var reloader = UITableViewReloader(tableView)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
        let button = UIButton(type: .roundedRect)
        button.setTitle("Reload", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 62)
        ])
        button.addTarget(self, action: #selector(reload), for: .touchUpInside)
        reload()
    }
    
    @objc
    func reload() {
        let array = (0..<20).map { UIKitCustomCell.Props($0) }.shuffled()
        reloader.reloadSections {
            CellsSection {
                SwiftUICell()
            }
            CellsSection(id: "array", data: array) { _ in
                UIKitCustomCell()
            }
            .cellsWith(\.height, 50)
        }
    }
}

final class UIKitCustomCell: UIView {
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIKitCustomCell: RenderableView {
    
    struct Props: Identifiable {
        
        var id: String
        var title: String
    
        init(id: String, title: String) {
            self.id = id
            self.title = title
        }
        
        init(_ i: Int) {
            self.init(id: "\(i)", title: "Item \(i)")
        }
    }
    
    func render(with props: Props) {
        label.text = props.title
    }
}

struct SwiftUICell: View {
    
    var body: some View {
        HStack {
            VStack {
                Text("Hello World")
                Text("Hello World")
                Spacer()
            }
            Spacer()
            Text("Hello World")
                .frame(maxHeight: .infinity, alignment: .topTrailing)
        }
        .padding()
        .frame(height: 60)
    }
}

