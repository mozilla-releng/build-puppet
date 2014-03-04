import diamond.collector
import json


def instance_type_to_int(instance_type):
    instance_class = {
        't1': 1,
        'm1': 2,
        'm2': 3,
        'm3': 4,
        'c1': 8,
        'c2': 9,
        'c3': 10,
    }
    instance_size = {
        'micro': 1,
        'medium': 2,
        'large': 3,
        'xlarge': 4,
        '2xlarge': 5,
        '4xlarge': 6,
        '8xlarge': 7,
    }
    """Takes an instance type and converts it to an integer via the following encoding:
        The instance class (e.g. t1, m1, m3) are looked up via the instance_class dict
        The instance size (e.g. micro, medium, large) are looked up via the instance_size dict

        Both components default to 0 if not found

        Returns (instance_class << 8) + instance_size
    """
    class_, size = instance_type.split(".")
    return (instance_class.get(class_, 0) << 8) + instance_size.get(size, 0)


class InstanceMetadataCollector(diamond.collector.Collector):
    def collect(self):
        instance_metadata = json.load(open("/etc/instance_metadata.json"))
        if instance_metadata.get('aws_instance_type'):
            self.publish('aws_instance_type',
                         instance_type_to_int(instance_metadata['aws_instance_type']))
